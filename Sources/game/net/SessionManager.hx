package game.net;

import ui.ErrorPage;
import peerjs.Peer;
import game.net.PacketType;
import game.mediators.FrameCounter;
import haxe.Timer;
import kha.Scheduler;
import peerjs.DataConnection;

class SessionManager {
	final peer: Peer;
	final frameCounter: FrameCounter;

	var dc: DataConnection;

	var roundTripCounter: Int;
	var localAdvantageCounter: Int;
	var remoteAdvantageCounter: Int;
	var lastLocalChecksum: Null<String>;
	var lastRemoteChecksum: Null<String>;
	var desyncCounter: Int;
	var lastConfirmedFrame: Int;

	var beginFrame: Null<Int>;
	var nextChecksumFrame: Null<Int>;
	var latestChecksumFrame: Int;

	var localInputHistory: Array<InputHistoryEntry>;
	var lastInputFrame: Int;

	var syncPackageTimeTaskID: Int;
	var syncPackageTimeoutTaskID: Int;
	var sendBeginTaskID: Int;
	var sendChecksumTaskID: Int;
	var syncTimeoutTaskID: Int;
	var checksumPackageTimeoutTaskID: Int;

	public final localID: String;
	public final remoteID: String;

	public var onInput(null, default): Array<InputHistoryEntry>->Void;
	public var onCalculateChecksum(null, default): Void->String;
	public var onConfirmFrame(null, default): Void->Void;

	public var averageRTT(default, null): Null<Int>;
	public var averageLocalAdvantage(default, null): Null<Int>;
	public var averageRemoteAdvantage(default, null): Null<Int>;
	public var successfulSleepChecks(default, null): Null<Int>;
	public var state(default, null): SessionState;
	public var sleepFrames(default, null): Int;

	public var isInputIdle: Bool;

	public function new(peer: Peer, isHost: Bool, remoteID: String) {
		this.peer = peer;
		frameCounter = new FrameCounter();

		if (isHost) {
			peer.on(PeerEventType.Connection, initDataConnection);
		} else {
			initDataConnection(peer.connect(remoteID, {
				serialization: PeerDataSerialization.None
			}));
		}

		localInputHistory = [];

		localID = peer.id;
		this.remoteID = remoteID;

		state = WAITING;
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function error(message: String) {
		dispose();
		ScreenManager.pushOverlay(ErrorPage.mainMenuPage(message));
	}

	function compareChecksums() {
		if (lastLocalChecksum == null || lastRemoteChecksum == null) {
			return;
		}

		if (lastLocalChecksum != lastRemoteChecksum) {
			if (++desyncCounter >= 3) {
				error("Desync Detected");
			}
		} else {
			desyncCounter = 0;
		}

		lastLocalChecksum = null;
		lastRemoteChecksum = null;
	}

	function initDataConnection(dc: DataConnection) {
		this.dc = dc;

		dc.on(DataConnectionEventType.Open, () -> {
			initSyncingState();
		});

		dc.on(DataConnectionEventType.Data, onMessage);
	}

	function onMessage(msg: String) {
		final parts = msg.split(";");

		switch ((parts[0] : PacketType)) {
			case SYNC_REQ:
				onSyncRequest(parts);
			case SYNC_RESP:
				onSyncResponse(parts);
			case INPUT if (state == RUNNING):
				onInputPacket(parts);
			case INPUT_ACK if (state == RUNNING):
				onInputAckPacket(parts);
			case BEGIN_REQ if (state == BEGINNING):
				onBeginRequest(parts);
			case BEGIN_RESP if (state == BEGINNING):
				onBeginResponse(parts);
			case CHECKSUM_REQ if (state == RUNNING):
				onChecksumRequest(parts);
			case CHECKSUM_RESP if (state == RUNNING):
				onChecksumResponse(parts);
			case CHECKSUM_UPDATE if (state == RUNNING):
				onChecksumUpdate(parts);
			default:
		}
	}

	function initSyncingState() {
		roundTripCounter = 0;
		localAdvantageCounter = 0;
		remoteAdvantageCounter = 0;
		successfulSleepChecks = 0;

		sleepFrames = 0;

		setSyncInterval(100);

		syncTimeoutTaskID = Scheduler.addTimeTask(() -> {
			error("Synchronization Failed");
		}, 15);

		isInputIdle = true;

		state = SYNCING;
	}

	function sendSyncRequest() {
		final ping = Std.int(Timer.stamp() * 1000);

		var prediction: Null<Int> = null;

		if (averageRTT != null) {
			prediction = frameCounter.value + Std.int(averageRTT / 2 * 60 / 1000);
		}

		dc.send('$SYNC_REQ;$ping;$prediction;${state == RUNNING ? "R" : "O"}');
	}

	function onSyncRequest(parts: Array<String>) {
		Scheduler.removeTimeTask(syncPackageTimeoutTaskID);

		syncPackageTimeoutTaskID = Scheduler.addTimeTask(() -> {
			error("Peer Disconnected (Sync Package Timeout)");
		}, 2);

		final pong = parts[1];
		final prediction = Std.parseInt(parts[2]);

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - prediction;

			averageLocalAdvantage = Math.round(0.5 * adv + 0.5 * averageLocalAdvantage);
		}

		if (state == SYNCING && parts[3] == "R")
			initRunningState();

		dc.send('$SYNC_RESP;$pong;$adv');
	}

	function onSyncResponse(parts: Array<String>) {
		final pong = Std.parseInt(parts[1]);
		final rtt = Std.int(Timer.stamp() * 1000) - pong;

		averageRTT = Math.round(0.5 * rtt + 0.5 * averageRTT);

		final adv = Std.parseInt(parts[2]);

		if (adv != null) {
			averageRemoteAdvantage = Math.round(0.5 * adv + 0.5 * averageRemoteAdvantage);

			if (sleepFrames == 0 && ++remoteAdvantageCounter % 3 == 0) {
				final diff = averageLocalAdvantage - averageRemoteAdvantage;

				if (state == SYNCING && Math.abs(diff) < 4) {
					if (++successfulSleepChecks > 5) {
						initBeginningState();

						return;
					}
				} else {
					successfulSleepChecks = 0;
				}

				if (!isInputIdle) {
					sleepFrames = 0;
					return;
				}

				if (averageLocalAdvantage < averageRemoteAdvantage) {
					sleepFrames = 0;
					return;
				}

				final diff = averageLocalAdvantage - averageRemoteAdvantage;
				final s = Math.ceil(diff / 2);

				if (s < 2) {
					sleepFrames = 0;
					return;
				}

				sleepFrames = Std.int(Math.min(s, 9));
			}
		}
	}

	function initBeginningState() {
		Scheduler.removeTimeTask(syncTimeoutTaskID);

		sendBeginTaskID = Scheduler.addTimeTask(() -> {
			dc.send('$BEGIN_REQ');
		}, 0, 0.001);

		state = BEGINNING;
	}

	function onBeginRequest(parts: Array<String>) {
		dc.send('$BEGIN_RESP;$beginFrame');
	}

	function onBeginResponse(parts: Array<String>) {
		beginFrame = Std.parseInt(parts[1]);

		if (beginFrame == null) {
			beginFrame = frameCounter.value + 60;
			return;
		}

		Scheduler.removeTimeTask(sendBeginTaskID);
	}

	function onInputPacket(parts: Array<String>) {
		final history = new Array<InputHistoryEntry>();

		var i = 1;
		var lastFrame = -1;

		while (i < parts.length) {
			final frame = Std.parseInt(parts[i]);
			final actions = Std.parseInt(parts[i + 1]);

			history.push({
				frame: frame,
				actions: actions
			});

			i += 2;

			lastFrame = frame;
		}

		if (lastFrame < lastInputFrame) {
			return;
		}

		dc.send('$INPUT_ACK;$lastFrame');

		onInput(history);

		lastInputFrame = lastFrame;
	}

	function onInputAckPacket(parts: Array<String>) {
		final frame = Std.parseInt(parts[1]);

		if (frame <= lastConfirmedFrame) {
			return;
		}

		localInputHistory = localInputHistory.filter(e -> e.frame > frame);
		lastConfirmedFrame = frame;

		onConfirmFrame();
	}

	function onChecksumRequest(parts: Array<String>) {
		dc.send('$CHECKSUM_RESP;$nextChecksumFrame');
	}

	function onChecksumResponse(parts: Array<String>) {
		nextChecksumFrame = Std.parseInt(parts[1]);

		if (nextChecksumFrame != null && nextChecksumFrame <= frameCounter.value) {
			nextChecksumFrame = null;
			return;
		}

		if (nextChecksumFrame == null) {
			nextChecksumFrame = frameCounter.value + 120;
			return;
		}

		latestChecksumFrame = nextChecksumFrame;
	}

	function onChecksumUpdate(parts: Array<String>) {
		resetChecksumTimeoutTimer();

		lastRemoteChecksum = parts[1];

		compareChecksums();
	}

	function updateSleepCounter() {
		if (sleepFrames > 0) {
			sleepFrames--;
		}

		return sleepFrames;
	}

	function initRunningState() {
		setSyncInterval(500);

		lastInputFrame = -1;
		lastConfirmedFrame = -1;
		desyncCounter = 0;
		latestChecksumFrame = -1;

		sendChecksumTaskID = Scheduler.addTimeTask(() -> {
			dc.send('$CHECKSUM_REQ');
		}, 0, 0.5);

		resetSyncTimeoutTimer();
		resetChecksumTimeoutTimer();

		state = RUNNING;
	}

	function updateBeginningState() {
		if (frameCounter.value == beginFrame) {
			initRunningState();

			return;
		}

		frameCounter.update();
	}

	function updateRunningState() {
		if (updateSleepCounter() > 0) {
			return;
		}

		if (frameCounter.value == latestChecksumFrame) {
			lastLocalChecksum = onCalculateChecksum();

			dc.send('$CHECKSUM_UPDATE;$lastLocalChecksum');

			nextChecksumFrame = null;

			compareChecksums();
		}

		frameCounter.update();
	}

	function resetSyncTimeoutTimer() {
		Scheduler.removeTimeTask(syncPackageTimeoutTaskID);

		syncPackageTimeoutTaskID = Scheduler.addTimeTask(() -> {
			error("Peer Disconnected (Sync Package Timeout)");
		}, 2);
	}

	function resetChecksumTimeoutTimer() {
		Scheduler.removeTimeTask(checksumPackageTimeoutTaskID);

		checksumPackageTimeoutTaskID = Scheduler.addTimeTask(() -> {
			error("Peer Disconnected (Checksum Package Timeout)");
		}, 3);
	}

	public function setSyncInterval(interval: Int) {
		Scheduler.removeTimeTask(syncPackageTimeTaskID);

		syncPackageTimeTaskID = Scheduler.addTimeTask(sendSyncRequest, 0, interval / 1000);
	}

	public function sendInput(frame: Int, actions: Int) {
		localInputHistory.push({frame: frame, actions: actions});

		var msg = '$INPUT';

		for (e in localInputHistory) {
			msg += ';${e.frame};${e.actions}';
		}

		dc.send(msg);
	}

	public function dispose() {
		Scheduler.removeTimeTask(syncPackageTimeTaskID);
		Scheduler.removeTimeTask(syncPackageTimeoutTaskID);
		Scheduler.removeTimeTask(sendChecksumTaskID);
		Scheduler.removeTimeTask(syncTimeoutTaskID);
		Scheduler.removeTimeTask(checksumPackageTimeoutTaskID);

		peer.destroy();
	}

	public function update() {
		switch (state) {
			case BEGINNING:
				updateBeginningState();
			case SYNCING | RUNNING:
				updateRunningState();
			default:
		}
	}
}

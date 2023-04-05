package game.net;

import main.ScreenManager;
import game.net.logger.ISessionLogger;
import ui.ErrorPage;
import peerjs.Peer;
import game.net.PacketType;
import game.mediators.FrameCounter;
import haxe.Timer;
import kha.Scheduler;
import peerjs.DataConnection;
import game.Macros;

@:structInit
@:build(game.Macros.buildOptionsClass(SessionManager))
class SessionManagerOptions {
	public final peer: Peer;
	public final isHost: Bool;
}

class SessionManager {
	@inject final frameCounter: FrameCounter;
	@inject final logger: ISessionLogger;
	final peer: Peer;

	var dc: DataConnection;

	var roundTripCounter: Int;
	var localAdvantageCounter: Int;
	var remoteAdvantageCounter: Int;
	var lastLocalChecksum: Null<String>;
	var lastRemoteChecksum: Null<String>;
	var desyncCounter: Int;
	var nextScheduledSleep: Int;

	var beginFrame: Null<Int>;
	var nextChecksumFrame: Null<Int>;
	var latestChecksumFrame: Int;

	var localInputHistory: Array<InputHistoryEntry>;

	var syncPackageTimeTaskID: Int;
	var syncPackageTimeoutTaskID: Int;
	var sendBeginTaskID: Int;
	var sendChecksumTaskID: Int;
	var syncTimeoutTaskID: Int;
	var checksumPackageTimeoutTaskID: Int;

	public final localID: String;
	@inject public final remoteID: String;

	public var onInput(null, default): Array<InputHistoryEntry>->Void;
	public var onCalculateChecksum(null, default): Void->String;
	public var onConfirmFrame(null, default): Void->Void;

	public var averageRTT(default, null): Null<Int>;
	public var averageLocalAdvantage(default, null): Null<Int>;
	public var averageRemoteAdvantage(default, null): Null<Int>;
	public var successfulSleepChecks(default, null): Null<Int>;
	public var state(default, null): SessionState;
	public var sleepFrames(default, null): Int;
	public var lastConfirmedFrame(default, null): Int;

	public var isInputIdle: Bool;

	public function new(opts: SessionManagerOptions) {
		Macros.initFromOpts();

		if (opts.isHost) {
			peer.on(PeerEventType.Connection, initDataConnection);
		} else {
			initDataConnection(peer.connect(remoteID, {
				serialization: PeerDataSerialization.None
			}));
		}

		localInputHistory = [];

		localID = peer.id;

		state = WAITING;
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function error(message: String) {
		logger.push('=== ERROR ===');
		logger.push(message);
		logger.download();

		dispose();
		ScreenManager.pushOverlay(ErrorPage.mainMenuPage(message));
	}

	function compareChecksums() {
		if (lastLocalChecksum == null || lastRemoteChecksum == null) {
			return;
		}

		if (lastLocalChecksum != lastRemoteChecksum) {
			logger.push('CHECKSUM MISMATCH -- Counter: $desyncCounter');
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
		logger.push('=== SYNCING STATE ===');

		roundTripCounter = 0;
		localAdvantageCounter = 0;
		remoteAdvantageCounter = 0;
		successfulSleepChecks = 0;
		nextScheduledSleep = 0;
		
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

		final state = state == RUNNING ? "R" : "O";

		logger.push('SEND SYNC_REQ -- Ping: $ping, Prediction: $prediction, State: $state');

		dc.send('$SYNC_REQ;$ping;$prediction;$state');
	}

	function onSyncRequest(parts: Array<String>) {
		Scheduler.removeTimeTask(syncPackageTimeoutTaskID);

		syncPackageTimeoutTaskID = Scheduler.addTimeTask(() -> {
			error("Peer Disconnected (Sync Package Timeout)");
		}, 2);

		final pong = parts[1];
		final prediction = Std.parseInt(parts[2]);
		final st = parts[3];

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - prediction;

			averageLocalAdvantage = Math.round(0.5 * adv + 0.5 * averageLocalAdvantage);
		}

		logger.push('RECV SYNC_REQ -- Pong: $pong, Prediction: $prediction, State: $st -- Average local adv: $averageLocalAdvantage');

		if (state == SYNCING && st == "R") {
			logger.push('SKIPPING SYNCING STATE');
			initRunningState();
		}

		logger.push('SEND SYNC_RESP -- Pong: $pong, Advantage: $adv');

		dc.send('$SYNC_RESP;$pong;$adv');
	}

	function onSyncResponse(parts: Array<String>) {
		final pong = Std.parseInt(parts[1]);
		final rtt = Std.int(Timer.stamp() * 1000) - pong;

		averageRTT = Math.round(0.5 * rtt + 0.5 * averageRTT);

		final adv = Std.parseInt(parts[2]);

		logger.push('RECV SYNC_RESP -- Pong: $pong, Advantage: $adv -- RTT: $rtt, Average RTT: $averageRTT');

		if (adv != null) {
			averageRemoteAdvantage = Math.round(0.5 * adv + 0.5 * averageRemoteAdvantage);

			logger.push('Average remote adv: $averageRemoteAdvantage');

			if (sleepFrames == 0 && ++remoteAdvantageCounter % 3 == 0) {
				final diff = averageLocalAdvantage - averageRemoteAdvantage;

				if (state == SYNCING) {
					if (Math.abs(diff) < 4) {
						logger.push('Succesful sleep check -- Counter: $successfulSleepChecks');
						if (++successfulSleepChecks > 5) {
							initBeginningState();

							return;
						}
					} else {
						logger.push('Advantage diff too large (L: $averageLocalAdvantage, R: $averageRemoteAdvantage, D: $diff), resetting sleep counter');
						successfulSleepChecks = 0;
					}
				}

				if (averageLocalAdvantage < averageRemoteAdvantage) {
					logger.push('Local adv. ($averageLocalAdvantage) < Remote adv. ($averageRemoteAdvantage), skipping sleep');
					nextScheduledSleep = 0;
					return;
				}

				final diff = averageLocalAdvantage - averageRemoteAdvantage;
				final s = Math.ceil(diff / 2);

				if (s < 2) {
					nextScheduledSleep = 0;
					return;
				}

				nextScheduledSleep = Std.int(Math.min(s, 9));
				logger.push('Scheduled sleep for $nextScheduledSleep frames');
			}
		}
	}

	function initBeginningState() {
		logger.push('=== BEGINNING STATE ===');

		Scheduler.removeTimeTask(syncTimeoutTaskID);

		sendBeginTaskID = Scheduler.addTimeTask(() -> {
			logger.push('SEND BEGIN_REQ');
			dc.send('$BEGIN_REQ');
		}, 0, 0.016);

		state = BEGINNING;
	}

	function onBeginRequest(parts: Array<String>) {
		logger.push('RECV BEGIN_REQ');
		logger.push('SEND BEGIN_RESP -- Begin frame: $beginFrame');
		dc.send('$BEGIN_RESP;$beginFrame');
	}

	function onBeginResponse(parts: Array<String>) {
		beginFrame = Std.parseInt(parts[1]);

		logger.push('RECV BEGIN_RESP -- Begin frame: $beginFrame');

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

		logger.push('RECV INPUT -- History size: ${history.length}');
		logger.push('SEND INPUT_ACK -- Last frame: $lastFrame');
		dc.send('$INPUT_ACK;$lastFrame');

		if (lastFrame < lastConfirmedFrame) {
			logger.push('Received INPUT is old: $lastFrame < $lastConfirmedFrame');
			return;
		}

		onInput(history);

		lastConfirmedFrame = lastFrame;

		onConfirmFrame();
	}

	function onInputAckPacket(parts: Array<String>) {
		final frame = Std.parseInt(parts[1]);

		logger.push('RECV INPUT_ACK -- Frame: $frame');
		localInputHistory = localInputHistory.filter(e -> e.frame > frame);

		if (frame <= lastConfirmedFrame) {
			return;
		}

		lastConfirmedFrame = frame;

		onConfirmFrame();
	}

	function onChecksumRequest(parts: Array<String>) {
		logger.push('RECV CHECKSUM_REQ');
		logger.push('SEND CHECKSUM_RESP -- Next frame: $nextChecksumFrame');
		dc.send('$CHECKSUM_RESP;$nextChecksumFrame');
	}

	function onChecksumResponse(parts: Array<String>) {
		nextChecksumFrame = Std.parseInt(parts[1]);

		logger.push('RECV CHECKSUM_RESP -- Next frame: $nextChecksumFrame');

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
		logger.push('RECV CHECKSUM_UPDATE -- Last remote: $lastRemoteChecksum');

		compareChecksums();
	}

	function updateSleepCounter() {
		if (isInputIdle && nextScheduledSleep > 0) {
			sleepFrames = nextScheduledSleep;
			nextScheduledSleep = 0;
		}

		if (sleepFrames > 0) {
			logger.push('SLEEPING -- Frame $sleepFrames');
			sleepFrames--;
		}

		return sleepFrames;
	}

	function initRunningState() {
		logger.push('=== RUNNING STATE ===');
		logger.useGameLog = true;

		setSyncInterval(500);

		lastConfirmedFrame = -1;
		desyncCounter = 0;
		latestChecksumFrame = -1;

		sendChecksumTaskID = Scheduler.addTimeTask(() -> {
			logger.push('SEND CHECKSUM_REQ');
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

			logger.push('SEND CHECKSUM_UPDATE -- Last local: $lastLocalChecksum');
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

		logger.push('SEND INPUT -- Frame: $frame, History size: ${localInputHistory.length}');
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

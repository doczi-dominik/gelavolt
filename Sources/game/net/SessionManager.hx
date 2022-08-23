package game.net;

import ui.ErrorPage;
import peerjs.Peer;
import game.net.PacketType;
import game.mediators.FrameCounter;
import haxe.Timer;
import kha.Scheduler;
import peerjs.DataConnection;

class SessionManager {
	final frameCounter: FrameCounter;

	var dc: DataConnection;

	var syncTimeTaskID: Int;
	var roundTripCounter: Int;
	var localAdvantageCounter: Int;
	var remoteAdvantageCounter: Int;

	var sleepFrames: Int;
	var internalSleepCounter: Int;

	var sendBeginTaskID: Int;
	var beginFrame: Null<Int>;

	var localInputHistory: Array<InputHistoryEntry>;
	var lastInputFrame: Int;
	var syncTimeoutTaskID: Int;

	public var onInput(null, default): Array<InputHistoryEntry>->Void;
	public var isInputIdle(null, default): Bool;

	public var averageRTT(default, null): Null<Int>;
	public var averageLocalAdvantage(default, null): Null<Int>;
	public var averageRemoteAdvantage(default, null): Null<Int>;
	public var successfulSleepChecks(default, null): Null<Int>;
	public var state(default, null): SessionState;

	public function new(peer: Peer, isHost: Bool, remoteID: String) {
		frameCounter = new FrameCounter();

		if (isHost) {
			peer.on(PeerEventType.Connection, initDataConnection);
		} else {
			initDataConnection(peer.connect(remoteID, {
				serialization: PeerDataSerialization.None
			}));
		}

		localInputHistory = [];

		state = WAITING;
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
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

		final type: PacketType = Std.parseInt(parts[0]);

		switch (type) {
			case SYNC_REQ:
				onSyncRequest(parts);
			case SYNC_RESP:
				onSyncResponse(parts);
			case INPUT:
				onInputPacket(parts);
			case INPUT_ACK:
				onInputAckPacket(parts);
			case BEGIN_REQ:
				onBeginRequest(parts);
			case BEGIN_RESP:
				onBeginResponse(parts);
		}
	}

	function initSyncingState() {
		roundTripCounter = 0;
		localAdvantageCounter = 0;
		remoteAdvantageCounter = 0;

		sleepFrames = 0;
		internalSleepCounter = 0;

		setSyncInterval(100);

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
		resetSyncTimeoutTimer();

		final pong = parts[1];
		final prediction = Std.parseInt(parts[2]);

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - prediction;

			averageLocalAdvantage = Math.round(0.5 * adv + 0.5 * averageLocalAdvantage);
		}

		if (parts[3] == "R")
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

			if (internalSleepCounter == 0 && ++remoteAdvantageCounter % 5 == 0) {
				final diff = averageLocalAdvantage - averageRemoteAdvantage;

				if (Math.abs(diff) < 4) {
					if (++successfulSleepChecks > 5) {
						initBeginningState();

						return;
					}
				} else {
					successfulSleepChecks = 0;
				}

				if (averageLocalAdvantage < averageRemoteAdvantage) {
					sleepFrames = 0;
					internalSleepCounter = 0;
					return;
				}

				final diff = averageLocalAdvantage - averageRemoteAdvantage;
				final s = Math.round(diff / 2);

				if (s < 2) {
					sleepFrames = 0;
					internalSleepCounter = 0;
					return;
				}

				sleepFrames = s;
				internalSleepCounter = s;
			}
		}
	}

	function initBeginningState() {
		sendBeginTaskID = Scheduler.addTimeTask(() -> {
			dc.send('$BEGIN_REQ');
		}, 0, 0.01);

		state = BEGINNING;
	}

	function onBeginRequest(parts: Array<String>) {
		dc.send('$BEGIN_RESP;$beginFrame');
	}

	function onBeginResponse(parts: Array<String>) {
		beginFrame = Std.parseInt(parts[1]);

		if (beginFrame == null) {
			beginFrame = frameCounter.value + Std.int(averageRTT * 10);
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

		localInputHistory = localInputHistory.filter(e -> e.frame > frame);
	}

	function initRunningState() {
		setSyncInterval(500);

		lastInputFrame = -1;

		state = RUNNING;
	}

	function updateSyncingState() {
		if (internalSleepCounter > 0) {
			internalSleepCounter--;
			return 0;
		}

		frameCounter.update();

		return 0;
	}

	function updateBeginningState() {
		if (frameCounter.value == beginFrame) {
			initRunningState();

			return 0;
		}

		frameCounter.update();

		return 0;
	}

	function updateRunningState() {
		if (isInputIdle) {
			final s = Std.int(Math.min(sleepFrames, 9));

			sleepFrames = 0;

			return s;
		}

		return 0;
	}

	function resetSyncTimeoutTimer() {
		Scheduler.removeTimeTask(syncTimeoutTaskID);

		syncTimeoutTaskID = Scheduler.addTimeTask(() -> {
			ScreenManager.pushOverlay(ErrorPage.mainMenuPage("Connection Error: Sync Package Timeout"));
		}, 2);
	}

	public function setSyncInterval(interval: Int) {
		Scheduler.removeTimeTask(syncTimeTaskID);

		syncTimeTaskID = Scheduler.addTimeTask(sendSyncRequest, 0, interval / 1000);
	}

	public function sendInput(frame: Int, actions: Int) {
		localInputHistory.push({frame: frame, actions: actions});

		var msg = '$INPUT';

		for (e in localInputHistory) {
			msg += ';${e.frame};${e.actions}';
		}

		dc.send(msg);
	}

	public function update() {
		return switch (state) {
			case SYNCING: updateSyncingState();
			case BEGINNING: updateBeginningState();
			case RUNNING: updateRunningState();
			default: 0;
		}
	}
}

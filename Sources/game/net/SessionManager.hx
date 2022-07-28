package game.net;

import game.net.PacketType;
import game.net.ServerMessageType;
import game.mediators.FrameCounter;
import haxe.Timer;
import haxe.io.Bytes;
import kha.Scheduler;
import haxe.net.WebSocket;

@:structInit
@:build(game.Macros.buildOptionsClass(SessionManager))
class SessionManagerOptions {}

class SessionManager {
	@inject final serverUrl: String;
	@inject final roomCode: String;
	@inject final frameCounter: FrameCounter;

	var ws: WebSocket;

	var syncTimeTaskID: Int;

	var lastSyncRequestTimestamp: Float;
	var roundTripCounter: Int;
	var averageLocalAdvantage: Int;
	var localAdvantageCounter: Int;
	var averageRemoteAdvantage: Int;
	var remoteAdvantageCounter: Int;
	var successfulSleepChecks: Int;

	// var beginFrame: Null<Int>;
	var netplayOptions: NetplayOptions;

	var sleepFrames: Int;

	public var onInput(null, default): (Int, Int) -> Void;
	public var onBegin(null, default): NetplayOptions->Void;

	public var averageRTT(default, null): Null<Int>;
	public var state(default, null): SessionState;
	public var beginFrame(default, null): Null<Int>;

	public function new(opts: SessionManagerOptions) {
		Macros.initFromOpts();

		netplayOptions = {
			builderType: VERSUS,
			rule: {},
			rngSeed: 24,
			isOnLeftSide: true
		};

		initConnectingState();
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function onClose(?e: Null<Dynamic>) {
		trace('WS Closed: $e');
	}

	function onServerMessage(msg: Bytes) {
		switch ((msg.get(0) : ServerMessageType)) {
			case BEGIN_SYNC:
				initSyncingState();
		}
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
			case BEGIN_REQ:
				onBeginRequest(parts);
			case BEGIN_RESP:
				onBeginResponse(parts);
		}
	}

	function onError(msg: String) {
		trace('WS Error: $msg');
	}

	function initConnectingState() {
		ws = WebSocket.create("ws://" + serverUrl + "/" + roomCode);

		ws.onopen = initWaitingState;
		ws.onclose = onClose;
		ws.onmessageBytes = onServerMessage;
		ws.onmessageString = onMessage;
		ws.onerror = onError;

		#if sys
		Scheduler.addTimeTask(ws.process, 0, 0.001);
		#end

		state = CONNECTING;
	}

	function initWaitingState() {
		state = WAITING;
	}

	function initSyncingState() {
		roundTripCounter = 0;
		localAdvantageCounter = 0;
		remoteAdvantageCounter = 0;

		setSyncInterval(100);

		state = SYNCING;
	}

	function sendSyncRequest() {
		var prediction: Null<Int> = null;

		if (averageRTT != null) {
			prediction = frameCounter.value + Std.int(averageRTT * 60 / 1000);
		}

		lastSyncRequestTimestamp = Timer.stamp();

		ws.sendString('$SYNC_REQ;$prediction');
	}

	function onSyncRequest(parts: Array<String>) {
		final prediction = Std.parseInt(parts[1]);

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - prediction;

			averageLocalAdvantage = Math.round(0.4 * adv + 0.6 * averageLocalAdvantage);
		}

		ws.sendString('$SYNC_RESP;$adv');
	}

	function onSyncResponse(parts: Array<String>) {
		final d = Timer.stamp() - lastSyncRequestTimestamp;
		final rtt = Std.int(d * 1000);

		averageRTT = Math.round((0.4 * rtt) + (0.6) * averageRTT);

		final adv = Std.parseInt(parts[1]);

		if (adv != null) {
			averageRemoteAdvantage = Math.round(0.4 * adv + 0.6 * averageRemoteAdvantage);

			if (sleepFrames == 0 && ++remoteAdvantageCounter % 5 == 0) {
				final diff = averageLocalAdvantage - averageRemoteAdvantage;

				if (Math.abs(diff) < 3 && ++successfulSleepChecks > 10) {
					initBeginningState();
					return;
				}

				if (averageLocalAdvantage < averageRemoteAdvantage) {
					sleepFrames = 0;
					return;
				}

				final s = Std.int(Math.min(diff / 2, 9));

				if (s < 2) {
					sleepFrames = 0;
					return;
				}

				sleepFrames = s;
				successfulSleepChecks = 0;
			}
		}
	}

	function initBeginningState() {
		ws.sendString('$BEGIN_REQ');

		state = BEGINNING;
	}

	function onBeginRequest(parts: Array<String>) {
		ws.sendString('$BEGIN_RESP;$beginFrame');
	}

	function onBeginResponse(parts: Array<String>) {
		beginFrame = Std.parseInt(parts[1]);

		if (beginFrame == null) {
			beginFrame = frameCounter.value + Std.int(averageRTT * 10);
		}
	}

	function onInputPacket(parts: Array<String>) {
		final frame = Std.parseInt(parts[1]);
		final actions = Std.parseInt(parts[2]);

		onInput(frame, actions);
	}

	public function setSyncInterval(interval: Int) {
		Scheduler.removeTimeTask(syncTimeTaskID);

		syncTimeTaskID = Scheduler.addTimeTask(sendSyncRequest, 0, interval / 1000);
	}

	public function getSleepFrames() {
		final v = sleepFrames;

		sleepFrames = 0;

		return v;
	}

	public inline function sendInput(frame: Int, actions: Int) {
		ws.sendString('$INPUT;$frame;$actions');
	}

	public function waitForRunning() {
		if (state == BEGINNING && frameCounter.value == beginFrame) {
			setSyncInterval(1000);

			onBegin(netplayOptions);

			state = RUNNING;
		}
	}
}

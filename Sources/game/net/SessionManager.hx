package game.net;

import game.randomizers.Randomizer;
import haxe.Timer;
import haxe.io.Bytes;
import input.IInputDevice;
import game.rules.Rule;
import game.net.packets.BeginResponsePacket;
import game.net.packets.BeginRequestPacket;
import game.net.packets.InputPacket;
import game.mediators.FrameCounter;
import game.net.packets.SyncResponsePacket;
import game.net.packets.SyncRequestPacket;
import game.net.packets.PacketBase;
import kha.Scheduler;
import hxbit.Serializer;
import haxe.net.WebSocket;

@:structInit
@:build(game.Macros.buildOptionsClass(SessionManager))
class SessionManagerOptions {}

class SessionManager {
	@inject final serverUrl: String;
	@inject final roomCode: String;
	@inject final frameCounter: FrameCounter;
	@inject final rngSeed: Int;
	@inject final rule: Rule;
	@inject final localInputDevice: IInputDevice;

	final serializer: Serializer;

	var ws: WebSocket;

	var isHost: Bool;

	var syncTimeTaskID: Int;

	var lastSyncRequestTimestamp: Float;
	var roundTripCounter: Int;
	var averageLocalAdvantage: Int;
	var localAdvantageCounter: Int;
	var averageRemoteAdvantage: Int;
	var remoteAdvantageCounter: Int;
	var successfulSleepChecks: Int;

	var beginFrame: Null<Int>;
	var netplayOptions: NetplayOptions;

	var sleepFrames: Int;

	public var onInput(null, default): InputPacket->Void;
	public var onBegin(null, default): NetplayOptions->Void;

	public var averageRTT(default, null): Null<Int>;
	public var state(default, null): SessionState;

	public function new(opts: SessionManagerOptions) {
		Macros.initFromOpts();

		serializer = new Serializer();

		initConnectingState();
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	inline function sendPacket(packet: PacketBase) {
		trace('Before ws.send: ${(Scheduler.realTime() - lastSyncRequestTimestamp) * 1000}');
		ws.sendBytes(serializer.serialize(packet));
		trace('After ws.send: ${(Scheduler.realTime() - lastSyncRequestTimestamp) * 1000}');
	}

	function onClose(?e: Null<Dynamic>) {
		trace('WS Closed: $e');
	}

	function onMessage(msg: Bytes) {
		trace('onMessage: ${(Scheduler.realTime() - lastSyncRequestTimestamp) * 1000}');
		final packet = serializer.unserialize(msg, PacketBase);
		trace('After unserialize (${packet.type}): ${(Scheduler.realTime() - lastSyncRequestTimestamp) * 1000}');

		switch (packet.type) {
			case BEGIN_REQ:
				onBeginRequest(untyped packet);
			case BEGIN_RESP:
				onBeginResponse(untyped packet);
			case SYNC_REQ:
				onSyncRequest(untyped packet);
			case SYNC_RESP:
				onSyncResponse(untyped packet);
			case INPUT:
				onInput(untyped packet);
			default:
		}
	}

	function onServerMessage(msg: String) {
		switch ((msg : ServerMessageType)) {
			case BEGIN_SYNC:
				initSyncingState();
			default:
		}
	}

	function onError(msg: String) {
		trace('WS Error: $msg');
	}

	function initConnectingState() {
		ws = WebSocket.create("ws://" + serverUrl + "/" + roomCode);

		ws.onopen = initWaitingState;
		ws.onclose = onClose;
		ws.onmessageBytes = onMessage;
		ws.onmessageString = onServerMessage;
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

		setSyncInterval(2000);

		state = SYNCING;
	}

	function sendSyncRequest() {
		var prediction: Null<Int> = null;

		if (averageRTT != null) {
			prediction = frameCounter.value + Std.int(averageRTT * 60 / 1000);
		}

		lastSyncRequestTimestamp = Timer.stamp();
	}

	function confirmNoSleepFrames() {
		sleepFrames = 0;

		if (state != SYNCING)
			return;

		if (!isHost)
			return;

		if (successfulSleepChecks++ < 3)
			return;

		sendPacket(new BeginRequestPacket({
			rule: rule,
			rngSeed: rngSeed,
			isOnLeftSide: true,
			builderType: VERSUS
		}));
	}

	function onSyncRequest(packet: SyncRequestPacket) {
		final prediction = packet.framePrediction;

		var adv: Null<Int> = null;

		if (prediction != null) {
			adv = frameCounter.value - packet.framePrediction;

			averageLocalAdvantage = Math.round((averageLocalAdvantage * localAdvantageCounter + adv) / ++localAdvantageCounter);
		}

		sendPacket(new SyncResponsePacket(adv));
	}

	function onSyncResponse(packet: SyncResponsePacket) {
		trace('onSyncResponse: ${(Scheduler.realTime() - lastSyncRequestTimestamp) * 1000}');
		final d = Timer.stamp() - lastSyncRequestTimestamp;
		final rtt = Std.int(d * 1000);

		trace('RTT: $rtt');

		averageRTT = Math.round((averageRTT * roundTripCounter + rtt) / ++roundTripCounter);

		if (packet.frameAdvantage != null) {
			averageRemoteAdvantage = Math.round((averageRemoteAdvantage * remoteAdvantageCounter + packet.frameAdvantage) / ++remoteAdvantageCounter);

			if (sleepFrames == 0) {
				if (advantageSign(averageLocalAdvantage) == advantageSign(averageRemoteAdvantage)) {
					sleepFrames = 0;
					return;
				}

				final s = Std.int(Math.min((averageLocalAdvantage - averageRemoteAdvantage) / 2, 9));

				if (s < 2) {
					sleepFrames = 0;
					return;
				}

				sleepFrames = s;
			}
		}
	}

	function onBeginRequest(packet: BeginRequestPacket) {
		netplayOptions = packet.options;

		beginFrame = frameCounter.value + Std.int(averageRTT * 1.5);

		sendPacket(new BeginResponsePacket(beginFrame));
	}

	function onBeginResponse(packet: BeginResponsePacket) {
		beginFrame = packet.beginFrame;
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
		sendPacket(new InputPacket(frame, actions));
	}

	public function waitForRunning() {
		if (state == BEGINNING && frameCounter.value == beginFrame) {
			setSyncInterval(1000);

			onBegin(netplayOptions);

			state = RUNNING;
		}
	}
}

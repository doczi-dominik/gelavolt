package game.net;

import game.gamestatebuilders.IGameStateBuilderOptions;
import game.actionbuffers.ReceiveActionBuffer;
import game.actionbuffers.SenderActionBuffer;
import input.IInputDevice;
import game.rules.Rule;
import game.gamestatebuilders.VersusGameStateBuilder.VersusGameStateBuilderOptions;
import game.net.packets.BeginResponsePacket;
import game.net.packets.BeginRequestPacket;
import game.net.packets.InputPacket;
import game.mediators.FrameCounter;
import game.net.packets.SyncResponsePacket;
import game.net.packets.SyncRequestPacket;
import game.net.packets.PacketBase;
import tink.http.Client.fetch;
import tink.http.Fetch.CompleteResponse;
import tink.core.Error;
import utils.Utils.randomString;
import kha.Scheduler;
import utils.RingBuffer;
import hxbit.Serializer;

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
	final roundTrips: RingBuffer<Int>;
	final localAdvantages: RingBuffer<Int>;
	final remoteAdvantages: RingBuffer<Int>;

	var requestSendID: String;
	var responseSendID: String;

	var requestRecvID: String;
	var responseRecvID: String;

	var magic: String;
	var remoteMagic: String;

	var isHost: Bool;

	var syncTimeTaskID: Int;

	var lastSyncRequestTimestamp: Float;
	var roundTripCounter: Int;
	var advantageExchangeCounter: Int;
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
		roundTrips = new RingBuffer(10, 0);
		localAdvantages = new RingBuffer(5, 0);
		remoteAdvantages = new RingBuffer(5, 0);

		initConnectingState();
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function sendMcast(channel: String, packet: PacketBase, ?onError: Error->Void, ?onSuccess: CompleteResponse->Void) {
		fetch('http://$serverUrl/mcast/$channel?wsecret=$magic', {
			method: POST,
			body: serializer.serialize(packet)
		}).all().handle(function(o) switch o {
			case Success(data):
				if (onSuccess != null)
					onSuccess(data);
			case Failure(failure):
				if (onError == null)
					onError(failure);
		});
	}

	function sendRequest(packet: PacketBase, ?onError: Error->Void, ?onSuccess: CompleteResponse->Void) {
		if (onError == null) {
			onError = function(e) trace('Failed to send request $packet: $e');
		}

		sendMcast(requestSendID, packet, onError, onSuccess);
	}

	function sendResponse(packet: PacketBase, ?onError: Error->Void, ?onSuccess: CompleteResponse->Void) {
		if (onError == null) {
			onError = function(e) trace('Failed to send response $packet: $e');
		}

		sendMcast(responseSendID, packet, onError, onSuccess);
	}

	function listen(channel: String, dispatch: PacketBase->Void) {
		fetch('http://$serverUrl/mcast/$channel').all().handle(function(o) {
			switch o {
				case Success(data):
					final packet = serializer.unserialize(data.body.toBytes(), PacketBase);

					if (packet.magic != remoteMagic)
						return;

					dispatch(packet);
				case Failure(failure):
					trace('Failed to get packet: $failure');
			}

			listen(channel, dispatch);
		});
	}

	function listenForRequest() {
		listen(requestRecvID, function(packet) switch packet.type {
			case SYNC_REQ:
				onSyncRequest(cast(packet, SyncRequestPacket));
			case INPUT:
				onInput(cast(packet, InputPacket));
			case BEGIN_REQ:
				onBeginRequest(cast(packet, BeginRequestPacket));
			default:
		});
	}

	function listenForResponse() {
		listen(responseRecvID, function(packet) switch packet.type {
			case SYNC_RESP:
				onSyncResponse(cast(packet, SyncResponsePacket));
			case BEGIN_RESP:
				onBeginResponse(cast(packet, BeginResponsePacket));
			default:
		});
	}

	function initConnectingState() {
		requestSendID = randomString(8);
		responseSendID = randomString(8);

		magic = randomString(8);

		fetch('http://$serverUrl/sync/$roomCode?c=$requestSendID-$responseSendID-$magic').all().handle(function(o) switch o {
			case Success(data):
				switch (data.header.byName("httprelay-query")) {
					case Success(header):
						final parts = (header : String).substring(2).split("-");

						requestRecvID = parts[0];
						responseRecvID = parts[1];
						remoteMagic = parts[2];

						for (i in 0...8) {
							if (magic.charCodeAt(i) < remoteMagic.charCodeAt(i)) {
								isHost = true;
								break;
							}

							if (magic.charCodeAt(i) > remoteMagic.charCodeAt(i)) {
								isHost = false;
								break;
							}
						}

						listenForRequest();
						listenForResponse();

						initSyncingState();
					case Failure(failure):
						trace('No channels in connect response: $failure');
				}
			case Failure(failure):
				trace('Failed to send connect request: $failure');
		});

		state = CONNECTING;
	}

	function initSyncingState() {
		roundTripCounter = 0;
		advantageExchangeCounter = 0;

		setSyncInterval(100);

		state = SYNCING;
	}

	function sendSyncRequest() {
		lastSyncRequestTimestamp = Scheduler.realTime();

		var prediction: Null<Int> = null;

		if (averageRTT != null) {
			prediction = frameCounter.value + Std.int(averageRTT * 60 / 1000);
		}

		sendRequest(new SyncRequestPacket(magic, prediction));
	}

	function confirmNoSleepFrames() {
		sleepFrames = 0;

		if (state != SYNCING)
			return;

		if (!isHost)
			return;

		if (successfulSleepChecks++ < 3)
			return;

		sendRequest(new BeginRequestPacket(magic, {
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

			localAdvantages.add(adv);
		}

		sendResponse(new SyncResponsePacket(magic, adv));
	}

	function onSyncResponse(packet: SyncResponsePacket) {
		final rtt = Std.int((Scheduler.realTime() - lastSyncRequestTimestamp) * 1000);
		roundTrips.add(rtt);

		if (roundTripCounter++ == 10) {
			roundTripCounter = 0;

			var sum = 0;

			for (rtt in roundTrips.values) {
				sum += rtt;
			}

			averageRTT = Math.round(sum / roundTrips.size);
		}

		if (packet.frameAdvantage != null) {
			remoteAdvantages.add(packet.frameAdvantage);

			if (advantageExchangeCounter++ == 5) {
				advantageExchangeCounter = 0;

				var sum = 0;

				for (adv in localAdvantages.values) {
					sum += adv;
				}

				final localAvg = Std.int(sum / localAdvantages.size);

				sum = 0;

				for (adv in remoteAdvantages.values) {
					sum += adv;
				}

				final remoteAvg = Std.int(sum / remoteAdvantages.size);

				if (advantageSign(localAvg) == advantageSign(remoteAvg)) {
					sleepFrames = 0;
					return;
				}

				final s = Std.int(Math.min((localAvg - remoteAvg) / 2, 9));

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

		sendResponse(new BeginResponsePacket(magic, beginFrame));
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
		sendRequest(new InputPacket(magic, frame, actions));
	}

	public function waitForRunning() {
		if (state == BEGINNING && frameCounter.value == beginFrame) {
			setSyncInterval(1000);

			onBegin(netplayOptions);

			state = RUNNING;
		}
	}
}

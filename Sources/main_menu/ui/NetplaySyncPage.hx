package main_menu.ui;

import game.net.SessionManager;
import tink.http.Header.HeaderField;
import kha.graphics2.Graphics;
import input.AnyInputDevice;
import kha.Assets;
import ui.ControlDisplay;
import ui.Menu;
import kha.Font;
import ui.IMenuPage;
import utils.Utils.randomString;
import tink.http.Client.fetch;
import tink.http.Fetch.CompleteResponse;
import kha.Scheduler;
import tink.core.Outcome;
import tink.core.Error;

private enum abstract InnerState(Int) {
	final INIT;
	final RTT;
	final SYNC;
}

class NetplaySyncPage implements IMenuPage {
	static inline final FONT_SIZE = 48;

	final font: Font;
	final messages: Array<String>;
	final roundTrips: Array<Int>;
	final localAdvantages: Array<Int>;
	final remoteAdvantages: Array<Int>;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;
	var innerState: InnerState;

	var requestSendID: String;
	var responseRecvID: String;
	var requestRecvID: String;
	var responseSendID: String;

	var sendPingTaskID: Int;
	var rttRemaining: Int;
	var lastSendStamp: Null<Float>;
	var averageRtt: Int;

	var t: Int;
	var sendSyncTaskID: Int;
	var lastRemotePrediction: Null<Int>;
	var lastLocalConfirmation: Null<Int>;
	var averageAdvantage: Int;

	var sleepFrames: Int;

	var updateT: Int;
	var updateRate: Int;

	public final header: String;

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new() {
		font = Assets.fonts.Pixellari;
		messages = [];
		roundTrips = [];
		localAdvantages = [];
		remoteAdvantages = [];

		innerState = INIT;

		t = 5;

		sleepFrames = 0;

		updateT = 0;
		updateRate = 1;

		header = "Sync Test";

		controlDisplays = [{actions: [BACK], description: "Back"}];
	}

	function pushMessage(m: String) {
		if (messages.length >= 18) {
			messages.shift();
		}

		messages.push(m);
	}

	function init() {
		messages.resize(0);
		pushMessage("Starting Sync");

		requestSendID = randomString(8);
		responseSendID = randomString(8);

		pushMessage('Generated requestSendID: $requestSendID');
		pushMessage('Generated responseSendID: $responseSendID');

		pushMessage("Sending Relay sync to localhost:8080 using code 'test1234'");

		fetch('http://localhost:8080/sync/test1234?sync=$requestSendID-$responseSendID').all().handle(function(o) switch o {
			case Success(data):
				switch (data.header.byName("httprelay-query")) {
					case Success(header):
						final parts = (header : String).substring(5).split("-");

						requestRecvID = parts[0];
						responseRecvID = parts[1];

						pushMessage('requestRecvID: $requestRecvID');
						pushMessage('responseRecvID: $responseRecvID');

						onRequest();
						onResponse();

						initRTTState();
					case Failure(_):
						pushMessage("No channels in response");
				}
			case Failure(e):
				pushMessage('Request failed: $e');
		});
	}

	function sendPing() {
		lastSendStamp = Scheduler.realTime();

		fetch('http://localhost:8080/mcast/$requestSendID', {
			method: POST,
		}).all().handle(function(o) switch o {
			case Success(_):
			case Failure(e):
				pushMessage('Failed to send ping: ${e.code}');
		});
	}

	function onRequest() {
		fetch('http://localhost:8080/mcast/$requestRecvID').all().handle(function(o) {
			switch (innerState) {
				case INIT:
				case RTT:
					onPingRequest(o);
				case SYNC:
					onSyncRequest(o);
			}

			onRequest();
		});
	}

	function onResponse() {
		fetch('http://localhost:8080/mcast/$responseRecvID').all().handle(function(o) {
			switch (innerState) {
				case INIT:
				case RTT:
					onPingResponse(o);
				case SYNC:
					onSyncResponse(o);
			}

			onResponse();
		});
	}

	function onPingRequest(o: Outcome<CompleteResponse, Error>) {
		switch o {
			case Success(_):
				sendPingResponse();
			case Failure(e):
				pushMessage('Failed to receive ping: $e');
		}
	}

	function onSyncRequest(o: Outcome<CompleteResponse, Error>) {
		switch o {
			case Success(data):
				final parts = data.body.toString().split(";");
				final pred = Std.parseInt(parts[0]);

				final adv = t - pred;

				pushMessage('I\'m on $t, predicted $pred ($adv)');

				localAdvantages.push(adv);

				sendSyncResponse(adv);
			case Failure(_):
		}
	}

	function onPingResponse(o: Outcome<CompleteResponse, Error>) {
		switch o {
			case Success(_):
				if (lastSendStamp != null) {
					final now = Scheduler.realTime();
					final rtt = Std.int((now - lastSendStamp) * 1000);
					roundTrips.push(rtt);
				}

				if (--rttRemaining == 0) {
					Scheduler.removeTimeTask(sendPingTaskID);
					initSyncState();
				}
			case Failure(e):
				pushMessage('Failed to receive ping response: $e');
		}
	}

	inline function advantageSign(x: Int) {
		return x < 0 ? -1 : 1;
	}

	function onSyncResponse(o: Outcome<CompleteResponse, Error>) {
		switch o {
			case Success(data):
				final s = data.body.toString();
				remoteAdvantages.push(Std.parseInt(s));

				if (remoteAdvantages.length % 5 == 0) {
					var sum = 0;

					for (adv in localAdvantages) {
						sum += adv;
					}

					final localAvg = Std.int(sum / localAdvantages.length);

					sum = 0;

					for (adv in remoteAdvantages) {
						sum += adv;
					}

					final remoteAvg = Std.int(sum / remoteAdvantages.length);
					final s = Std.int(Math.min((localAvg - remoteAvg) / 2, 9));
					pushMessage('Sleep frames: $s');

					if (advantageSign(localAvg) == advantageSign(remoteAvg)) {
						pushMessage('Signs are equal, not sleeping');
						return;
					}

					if (s < 2)
						return;

					sleepFrames = s;
				}
			case Failure(e):
				pushMessage('Failed to receive remote advantage: $e');
		}
	}

	function sendPingResponse() {
		fetch('http://localhost:8080/mcast/$responseSendID', {
			method: POST,
		}).all().handle(function(o) switch o {
			case Success(_):
			case Failure(e):
				trace(e);
		});
	}

	function initRTTState() {
		roundTrips.resize(0);

		rttRemaining = 10;

		sendPingTaskID = Scheduler.addTimeTask(sendPing, 0, 0.1);

		innerState = RTT;
	}

	function sendSync() {
		lastRemotePrediction = t + Std.int((averageRtt * 60 / 1000));

		fetch('http://localhost:8080/mcast/$requestSendID', {
			method: POST,
			headers: [new HeaderField(CONTENT_TYPE, "text/plain")],
			body: '$lastRemotePrediction'
		}).all().handle(function(o) switch o {
			case Success(_):
			case Failure(e):
				pushMessage('Failed to send sync: ${e.data}');
		});
	}

	function sendSyncResponse(adv: Int) {
		fetch('http://localhost:8080/mcast/$responseSendID', {
			method: POST,
			body: '$adv'
		}).all().handle(function(o) switch o {
			case Success(_):
			case Failure(e):
				pushMessage('Failed to send sync: $e');
		});
	}

	function initSyncState() {
		var sum = 0;

		for (rtt in roundTrips) {
			sum += rtt;
		}

		averageRtt = Math.ceil(sum / roundTrips.length);
		pushMessage('Average RTT: $averageRtt');

		sendSyncTaskID = Scheduler.addTimeTask(sendSync, 0, 0.5);

		innerState = SYNC;
	}

	function updateSyncState() {
		if (sleepFrames > 0) {
			--sleepFrames;
			return;
		}

		if (updateT % updateRate == 0) {
			++t;
		}

		++updateT;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		init();
	}

	public function update() {
		final anyInput = AnyInputDevice.instance;

		if (anyInput.getAction(BACK)) {
			menu.popPage();

			return;
		}

		if (anyInput.getAction(MENU_LEFT)) {
			--updateRate;
		}

		if (anyInput.getAction(MENU_RIGHT)) {
			++updateRate;
		}

		if (anyInput.getAction(MENU_UP)) {
			--t;
		}

		if (anyInput.getAction(MENU_DOWN)) {
			++t;
		}

		switch (innerState) {
			case INIT:
			case RTT:
			case SYNC:
				updateSyncState();
		}
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		g.drawString('UPD Rate: $updateRate', x, y);
		g.drawString('T: $t', x, y + fontHeight);
		g.drawString('Frame advantage AVG: $averageAdvantage', x, y + fontHeight * 2);

		for (i in 0...messages.length) {
			g.drawString(messages[i], x, y + (i + 6) * fontHeight);
		}

		if (t % 500 == 0) {
			g.color = Red;
			g.fillRect(0, 0, 1920, 1080);
		}

		g.color = White;
	}
}

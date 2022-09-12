package lobby;

import kha.System;
import haxe.io.Bytes;
import hxbit.Serializer;
import game.rules.VersusRule;
import game.gamestatebuilders.NetplayEndlessGameStateBuilder;
import ui.ErrorPage;
import ui.MenuPageBase;
import main_menu.MainMenuScreen;
import game.net.SessionManager;
import game.screens.NetplayGameScreen;
import game.mediators.FrameCounter;
import kha.graphics2.Graphics;
import ui.Menu;
import io.colyseus.Room;
import io.colyseus.Client;
#if kha_html5
import js.Browser;
import peerjs.Peer;
#end

class LobbyPage extends MenuPageBase {
	static inline final RELAY_PORT_MESSAGE_TYPE = 1;
	static inline final SERVER_URL = "szi5os.colyseus.de";

	static function startGame(peer: Peer, isHost: Bool, message: String) {
		final parts = message.split(";");
		final s = new SessionManager(peer, isHost, parts[0]);
		final rule = Serializer.load(Bytes.ofHex(parts[1]), VersusRule);

		final f = new FrameCounter();

		ScreenManager.switchScreen(new NetplayGameScreen({
			session: s,
			frameCounter: f,
			gameStateBuilder: new NetplayEndlessGameStateBuilder({
				rule: rule,
				isLocalOnLeft: true,
				session: s,
				frameCounter: f
			})
		}));
	}

	static function addRoomHandler(peer: Peer, room: Room<WaitingRoomState>) {
		room.onMessage(1, msg -> {
			startGame(peer, true, msg);
		});

		room.onMessage(2, msg -> {
			startGame(peer, false, msg);
		});
	}

	#if kha_html5
	public static function handleURLJoin() {
		final roomID = Browser.location.hash.substring(1);

		if (roomID == "") {
			ScreenManager.switchScreen(new MainMenuScreen());
			return;
		}

		final peer = new Peer();

		peer.on(PeerEventType.Error, (err: PeerError) -> {
			ScreenManager.pushOverlay(ErrorPage.mainMenuPage('PeerError: $err'));
		});

		peer.on(PeerEventType.Open, peerID -> {
			new Client('wss://$SERVER_URL').joinById(roomID, ["peerID" => peerID], WaitingRoomState, (err, room) -> {
				if (err != null) {
					ScreenManager.pushOverlay(ErrorPage.mainMenuPage('Could Not Join Room: ${err.code} - ${err.message}'));
					return;
				}

				addRoomHandler(peer, room);
			});
		});
	}
	#end

	var room: Null<Room<WaitingRoomState>>;
	var roomURL: Null<String>;
	var showCopied: Bool;

	public function new() {
		super({
			designFontSize: 56,
			header: "Lobby",
			controlHints: [
				{actions: [BACK], description: "Leave"},
				{actions: [CONFIRM], description: "Copy Link To Clipboard"}
			]
		});
	}

	override function onShow(menu: Menu) {
		super.onShow(menu);

		if (roomURL != null)
			return;

		showCopied = false;

		final peer = new Peer();

		peer.on(PeerEventType.Error, (err: PeerError) -> {
			ScreenManager.pushOverlay(ErrorPage.mainMenuPage('PeerError: $err'));
		});

		peer.on(PeerEventType.Open, id -> {
			final rule: VersusRule = {
				rngSeed: Std.int(System.time * 1000000),
				marginTime: 96,
				targetPoints: 70,
				garbageDropLimit: 30,
				garbageConfirmGracePeriod: 30,
				softDropBonus: 0.5,
				popCount: 4,
				vanishHiddenRows: false,
				groupBonusTableType: TSU,
				colorBonusTableType: TSU,
				powerTableType: TSU,
				dropBonusGarbage: true,
				allClearReward: 30,
				physics: TSU,
				animations: TSU,
				dropSpeed: 2.6,
				randomizeGarbage: true,
			};

			new Client('wss://$SERVER_URL').create("waiting", ["peerID" => id, "rule" => Serializer.save(rule).toHex()], WaitingRoomState, (err, room) -> {
				if (err != null) {
					ScreenManager.pushOverlay(ErrorPage.mainMenuPage('Could Not Create Room: ${err.message}'));
					return;
				}

				this.room = room;
				roomURL = 'https://gelavolt.io/#${room.id}';

				Browser.navigator.clipboard.writeText(roomURL);

				addRoomHandler(peer, room);
			});
		});
	}

	override function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(BACK)) {
			if (room != null)
				room.leave(true);

			menu.popPage();
		}

		if (roomURL != null && inputDevice.getAction(CONFIRM)) {
			Browser.navigator.clipboard.writeText(roomURL).then((_) -> {
				showCopied = true;
			});
		}
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		if (room == null) {
			g.drawString('Creating room...', x, y);
			return;
		}

		g.drawString("Waiting For Opponent...", x, y);
		g.drawString('Join Link: $roomURL', x, y + fontHeight);

		if (showCopied)
			g.drawString("Copied To Clipboard!", x, y + fontHeight * 2);
	}
}

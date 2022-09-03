package lobby;

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

	static function startGame(peer: Peer, isHost: Bool, remoteID: String) {
		final s = new SessionManager(peer, isHost, remoteID);

		final f = new FrameCounter();

		ScreenManager.switchScreen(new NetplayGameScreen({
			session: s,
			frameCounter: f,
			gameStateBuilder: new NetplayEndlessGameStateBuilder({
				rule: {
					rngSeed: 0,
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
				},
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

	public function new() {
		super({
			designFontSize: 56,
			header: "Lobby",
			controlHints: [{actions: [BACK], description: "Leave"}]
		});
	}

	override function onShow(menu: Menu) {
		super.onShow(menu);

		if (room != null)
			return;

		final peer = new Peer();

		peer.on(PeerEventType.Error, (err: PeerError) -> {
			ScreenManager.pushOverlay(ErrorPage.mainMenuPage('PeerError: $err'));
		});

		peer.on(PeerEventType.Open, id -> {
			new Client('wss://$SERVER_URL').create("waiting", ["peerID" => id], WaitingRoomState, (err, room) -> {
				if (err != null) {
					ScreenManager.pushOverlay(ErrorPage.mainMenuPage('Could Not Create Room: ${err.code} - ${err.message}'));
					return;
				}

				this.room = room;

				addRoomHandler(peer, room);
			});
		});
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		if (room == null) {
			g.drawString('Connecting...', x, y);
			return;
		}

		g.drawString("Waiting For Opponent...", x, y);
		g.drawString('Join Link: https://gelavolt.io/#${room.id}', x, y + fontHeight);
	}
}

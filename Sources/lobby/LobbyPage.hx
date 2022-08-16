package lobby;

import peerjs.Peer;
import haxe.net.WebSocket;
import main_menu.MainMenuScreen;
import game.gamestatebuilders.VersusGameStateBuilder;
import game.net.SessionManager;
import Screen.GlobalScreenSwitcher;
import game.screens.NetplayGameScreen;
import game.mediators.FrameCounter;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.ControlHint;
import ui.IMenuPage;
import io.colyseus.Room;
import io.colyseus.Client;
#if kha_html5
import js.Browser;
#end

class LobbyPage implements IMenuPage {
	static inline final FONT_SIZE = 48;
	static inline final RELAY_PORT_MESSAGE_TYPE = 1;
	static inline final SERVER_URL = "szi5os.colyseus.de";

	static function startGame(peer: Peer, isHost: Bool, remoteID: String) {
		final s = new SessionManager(peer, isHost, remoteID);

		final f = new FrameCounter();

		GlobalScreenSwitcher.switchScreen(new NetplayGameScreen({
			session: s,
			frameCounter: f,
			gameStateBuilder: new VersusGameStateBuilder({
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

		trace('ID: $roomID');

		if (roomID == "") {
			GlobalScreenSwitcher.switchScreen(new MainMenuScreen());
			return;
		}

		final peer = new Peer();

		peer.on(PeerEventType.Error, (err: PeerError) -> {
			trace('URL Join PeerError: $err');
		});

		peer.on(PeerEventType.Open, peerID -> {
			trace('Connected to PeerServer, ID: $peerID');
			new Client('wss://$SERVER_URL').joinById(roomID, ["peerID" => peerID], WaitingRoomState, (err, room) -> {
				if (err != null) {
					trace('Join error: $err');
					GlobalScreenSwitcher.switchScreen(new MainMenuScreen());
					return;
				}

				addRoomHandler(peer, room);
			});
		});
	}
	#end

	final font: Font;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;

	var room: Null<Room<WaitingRoomState>>;

	public final header: String;
	public final controlHints: Array<ControlHint>;

	public function new() {
		font = Assets.fonts.Pixellari;

		header = "Lobby";
		controlHints = [{actions: [BACK], description: "Leave"}];
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		if (room != null)
			return;

		final peer = new Peer();

		peer.on(PeerEventType.Error, (err: PeerError) -> {
			trace('Create PeerError: $err');
		});

		peer.on(PeerEventType.Open, id -> {
			trace('Connected to PeerServer, ID: $id');
			new Client('wss://$SERVER_URL').create("waiting", ["peerID" => id], WaitingRoomState, (err, room) -> {
				if (err != null) {
					trace('Create error: $err');
					return;
				}

				this.room = room;

				trace(room.id);

				addRoomHandler(peer, room);
			});
		});
	}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		if (room == null) {
			g.drawString('Connecting...', x, y);
			return;
		}

		g.drawString("Waiting For Opponent...", x, y);
		g.drawString('Join Link: https://gelavolt.io/#${room.id}', x, y + fontHeight);
	}
}

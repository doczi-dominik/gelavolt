package lobby;

import haxe.net.WebSocket;
import game.Macros;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.ControlHint;
import ui.IMenuPage;

@:structInit
@:build(game.Macros.buildOptionsClass(LobbyPage))
class LobbyPageOptions {}

class LobbyPage implements IMenuPage {
	static inline final FONT_SIZE = 32;

	@inject final url: String;
	@inject final lobbyCode: String;

	final ws: WebSocket;
	final players: Array<LobbyPlayer>;

	final font: Font;

	var menu: Menu;
	var fontSize: Int;

	public final header: String;
	public final controlHints: Array<ControlHint>;

	public function new(opts: LobbyPageOptions) {
		Macros.initFromOpts();
		players = [];

		font = Assets.fonts.Pixellari;

		header = "Lobby";
		controlHints = [
			{actions: [BACK], description: "Leave"},
			{actions: [CONFIRM], description: "Toggle Ready"}
		];

		ws = WebSocket.create(url);
		ws.onclose = onClose;
		ws.onerror = onError;
		ws.onmessageString = onMessage;
	}

	function onClose(?e: Null<Dynamic>) {
		trace("Lobby WS Closed");
	}

	function onError(?e: Null<Dynamic>) {
		trace("Lobby WS Error");
	}

	function onMessage(msg: String) {
		final parts = msg.split(";");

		final type: LobbyCommandType = Std.parseInt(parts[0]);

		switch (type) {
			case LOBBY_INIT_CMD:
				onInit(parts);
			case LOBBY_PLAYERS_UPDATE_CMD:
				onPlayersUpdate(parts);
			case LOBBY_START_GAME_CMD:
				onStartGame();
		}
	}

	function onInit(parts: Array<String>) {}

	function onPlayersUpdate(parts: Array<String>) {}

	function onStartGame() {}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		for (i in 0...players.length) {
			final p = players[i];
			final y = fontSize * 1.2 * i;

			g.drawString('Player ${i + 1}', 0, y);

			if (p.isReady) {
				g.color = Green;
				g.drawString('READY', 0, y);
			}

			g.color = White;
		}
	}
}

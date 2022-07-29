package game.screens;

import game.gamestatebuilders.IBackupGameStateBuilder;
import kha.graphics4.Graphics as Graphics4;
import kha.graphics2.Graphics;
import game.net.SessionManager;

@:structInit
@:build(game.Macros.buildOptionsClass(NetplayGameScreen))
class NetplayGameScreenOptions {
	public final gameStateBuilder: IBackupGameStateBuilder;
}

class NetplayGameScreen extends BackupStateGameScreen {
	@inject final session: SessionManager;

	public function new(opts: NetplayGameScreenOptions) {
		session = opts.session;

		super(opts.gameStateBuilder);
	}

	override function updateGameState() {
		session.update();

		if (session.state == RUNNING) {
			gameState.update();
		}
	}

	override function render(g: Graphics, g4: Graphics4, alpha: Float) {
		super.render(g, g4, alpha);

		g.font = font;
		g.fontSize = fontSize;

		final text = switch (session.state) {
			case CONNECTING: "Connecting To Relay...";
			case WAITING: "Waiting For Peer...";
			case SYNCING: "Synchronizing...";
			case BEGINNING: "Synchronized! Game will begin soon...";
			case RUNNING: 'RTT: ${session.averageRTT}';
		}

		g.drawString(text, 0, 0);
	}
}

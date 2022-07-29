package game.screens;

import game.gamestatebuilders.INetplayGameStateBuilder;
import game.net.SessionManager;

@:structInit
@:build(game.Macros.buildOptionsClass(NetplayGameScreen))
class NetplayGameScreenOptions {
	public final gameStateBuilder: INetplayGameStateBuilder;
}

class NetplayGameScreen extends BackupStateGameScreen {
	@inject final session: SessionManager;

	public function new(opts: NetplayGameScreenOptions) {
		session = opts.session;

		opts.gameStateBuilder.session = session;

		super(opts.gameStateBuilder);
	}

	override function updateGameState() {
		session.update();

		if (session.state == RUNNING) {
			gameState.update();
		}
	}
}

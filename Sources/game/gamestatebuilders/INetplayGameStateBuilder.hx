package game.gamestatebuilders;

import game.net.SessionManager;

@:allow(game.screens.GameScreenBase)
interface INetplayGameStateBuilder extends IBackupGameStateBuilder {
	public var session(null, default): Null<SessionManager>;
}

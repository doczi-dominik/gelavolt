package game.states;

import game.rules.MarginTimeManager;
import game.ui.PauseMenu;
import game.boardmanagers.IBoardManager;
import game.particles.IParticleManager;

@:structInit
class GameStateOptions {
	public final particleManager: IParticleManager;
	public final boardManager: IBoardManager;
	public final marginManager: MarginTimeManager;
	public final pauseMenu: PauseMenu;
}

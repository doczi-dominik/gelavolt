package game.states;

import game.mediators.FrameCounter;
import game.rules.MarginTimeManager;
import game.ui.PauseMenu;
import game.boardmanagers.IBoardManager;
import game.particles.ParticleManager;

@:structInit
class GameStateOptions {
	public final particleManager: ParticleManager;
	public final boardManager: IBoardManager;
	public final marginManager: MarginTimeManager;
	public final pauseMenu: PauseMenu;
	public final frameCounter: FrameCounter;
}

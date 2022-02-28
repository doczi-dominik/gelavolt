package game.ui;

import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;
import save_data.TrainingSave;

@:structInit
class EndlessPauseMenuOptions extends PauseMenuOptions {
	public final gameMode: EndlessGameMode;
	public final trainingSave: TrainingSave;
	public final actionBuffer: IActionBuffer;
}

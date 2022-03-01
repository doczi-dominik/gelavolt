package game.ui;

import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;
import save_data.TrainingSettings;

@:structInit
class EndlessPauseMenuOptions extends PauseMenuOptions {
	public final gameMode: EndlessGameMode;
	public final trainingSettings: TrainingSettings;
	public final actionBuffer: IActionBuffer;
}

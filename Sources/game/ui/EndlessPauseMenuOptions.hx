package game.ui;

import game.actionbuffers.IActionBuffer;
import save_data.TrainingSave;

@:structInit
class EndlessPauseMenuOptions extends PauseMenuOptions {
	public final trainingSave: TrainingSave;
	public final actionBuffer: IActionBuffer;
}

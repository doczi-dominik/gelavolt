package game.ui;

import game.mediators.PauseMediator;
import save_data.PrefsSave;

@:structInit
class PauseMenuOptions {
	public final prefsSave: PrefsSave;
	public final pauseMediator: PauseMediator;
}

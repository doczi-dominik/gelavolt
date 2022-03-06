package game.ui;

import game.mediators.PauseMediator;
import save_data.PrefsSettings;

@:structInit
class PauseMenuOptions {
	public final prefsSettings: PrefsSettings;
	public final pauseMediator: PauseMediator;
}

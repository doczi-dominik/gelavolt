package game.ui;

import game.mediators.ControlDisplayContainer;
import save_data.EndlessSettings;
import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;

@:structInit
class EndlessPauseMenuOptions extends PauseMenuOptions {
	public final gameMode: EndlessGameMode;
	public final endlessSettings: EndlessSettings;
	public final controlDisplayContainer: ControlDisplayContainer;
	public final actionBuffer: IActionBuffer;
}

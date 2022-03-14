package game.ui;

import save_data.EndlessSettings;
import game.gamemodes.EndlessGameMode;
import game.actionbuffers.IActionBuffer;

@:structInit
class EndlessPauseMenuOptions extends PauseMenuOptions {
	public final gameMode: EndlessGameMode;
	public final endlessSettings: EndlessSettings;
	public final actionBuffer: IActionBuffer;
}

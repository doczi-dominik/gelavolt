package game.gamestatebuilders;

import input.IInputDeviceManager;
import game.gamemodes.EndlessGameMode;
import game.mediators.TransformationMediator;

@:structInit
class EndlessGameStateBuilderOptions {
	public final gameMode: EndlessGameMode;
	public final transformMediator: TransformationMediator;
	public final inputManager: IInputDeviceManager;
}

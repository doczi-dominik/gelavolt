package game.gamestatebuilders;

import input.IInputDevice;
import game.gamemodes.EndlessGameMode;
import game.mediators.TransformationMediator;

@:structInit
class EndlessGameStateBuilderOptions {
	public final gameMode: EndlessGameMode;
	public final transformMediator: TransformationMediator;
	public final inputDevice: IInputDevice;
}

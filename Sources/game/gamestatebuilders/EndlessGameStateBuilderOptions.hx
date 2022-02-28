package game.gamestatebuilders;

import game.gamemodes.EndlessGameMode;
import game.mediators.TransformationMediator;

@:structInit
class EndlessGameStateBuilderOptions {
	public final gameMode: EndlessGameMode;
	public final transformMediator: TransformationMediator;
}

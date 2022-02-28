package game.gamestatebuilders;

import game.gamemodes.TrainingGameMode;
import game.mediators.TransformationMediator;

@:structInit
class TrainingGameStateBuilderOptions {
	public final gameMode: TrainingGameMode;
	public final transformMediator: TransformationMediator;
}

package game.gamemodes;

import game.rules.Rule;

@:structInit
class TrainingGameMode implements IGameMode {
	public final rngSeed: Int;
	public final rule: Rule;

	public var gameMode(default, never) = GameMode.TRAINING;
}

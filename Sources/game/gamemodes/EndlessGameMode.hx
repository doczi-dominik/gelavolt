package game.gamemodes;

import game.rules.Rule;
import save_data.Profile;

@:structInit
class EndlessGameMode implements IGameMode {
	public final profile: Profile;
	public final rngSeed: Int;
	public final rule: Rule;

	public var gameMode(default, never) = GameMode.ENDLESS;
}

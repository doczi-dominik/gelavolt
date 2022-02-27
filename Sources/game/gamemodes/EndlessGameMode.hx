package game.gamemodes;

import game.actionbuffers.ReplayData;
import game.rules.Rule;
import save_data.Profile;

@:structInit
class EndlessGameMode implements IGameMode {
	public final profile: Profile;
	public final rngSeed: Int;
	public final rule: Rule;

	@:optional public final replayData: Null<ReplayData>;

	public var gameMode(default, never) = GameMode.ENDLESS;
}

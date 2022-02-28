package game.gamemodes;

import game.actionbuffers.ReplayData;
import game.rules.Rule;

@:structInit
class EndlessGameMode implements IReplayableGameMode {
	public final rngSeed: Int;
	public final rule: Rule;

	@:optional public final replayData: Null<ReplayData>;

	public var gameMode(default, never) = GameMode.ENDLESS;

	public function copyWithReplay(data: ReplayData) {
		return ({
			rngSeed: rngSeed,
			rule: rule,
			replayData: data
		} : EndlessGameMode);
	}
}

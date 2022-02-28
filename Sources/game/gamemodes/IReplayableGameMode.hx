package game.gamemodes;

import game.actionbuffers.ReplayData;

interface IReplayableGameMode extends IGameMode {
	public final replayData: Null<ReplayData>;

	public function copyWithReplay(data: ReplayData): IReplayableGameMode;
}

package game.actionbuffers;

import game.copying.ICopyFrom;

interface IActionBuffer extends ICopyFrom {
	public var latestAction(get, never): ActionSnapshot;

	public function update(): Void;
	public function exportReplayData(): ReplayData;
}

package game.actionbuffers;

import game.copying.ICopyFrom;

interface IActionBuffer extends ICopyFrom {
	public function update(): ActionSnapshot;
	public function exportReplayData(): ReplayData;
}

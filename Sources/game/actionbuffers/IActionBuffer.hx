package game.actionbuffers;

interface IActionBuffer {
	public function update(): ActionSnapshot;
	public function exportReplayData(): ReplayData;
}

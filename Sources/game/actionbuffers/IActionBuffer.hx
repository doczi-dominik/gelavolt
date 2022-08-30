package game.actionbuffers;

interface IActionBuffer {
	public var isActive: Bool;

	public function update(): ActionSnapshot;
	public function exportReplayData(): ReplayData;
}

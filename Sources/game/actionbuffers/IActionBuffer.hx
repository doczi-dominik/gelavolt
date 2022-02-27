package game.actionbuffers;

interface IActionBuffer {
	public var latestAction(default, null): ActionSnapshot;

	public function update(): Void;
	public function exportReplayData(): ReplayData;
}

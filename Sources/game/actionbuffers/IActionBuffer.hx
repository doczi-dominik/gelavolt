package game.actionbuffers;

interface IActionBuffer {
	public function update(): ActionSnapshot;
	public function activate(): Void;
	public function deactivate(): Void;
	public function exportReplayData(): ReplayData;
}

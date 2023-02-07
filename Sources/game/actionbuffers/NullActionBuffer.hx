package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	public static final instance = new NullActionBuffer();

	final nullAction: ActionSnapshot;

	public var isActive = false;

	function new() {
		nullAction = ActionSnapshot.fromBitField(0);
	}

	public function copy(): Dynamic {
		return instance;
	}

	public function update() {
		return nullAction;
	}

	public function exportReplayData() {
		return new ReplayData();
	}
}

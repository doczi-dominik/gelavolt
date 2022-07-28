package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	public static var instance(get, null): NullActionBuffer;

	static function get_instance() {
		if (instance == null)
			instance = new NullActionBuffer();

		return instance;
	}

	final nullAction: ActionSnapshot;

	public var latestAction(get, never): ActionSnapshot;

	function new() {
		nullAction = ActionSnapshot.fromBitField(0);
	}

	function get_latestAction() {
		return nullAction;
	}

	public function copy() {
		return instance;
	}

	public function update() {}

	public function exportReplayData() {
		return new ReplayData();
	}
}

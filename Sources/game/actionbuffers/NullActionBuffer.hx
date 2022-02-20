package game.actionbuffers;

class NullActionBuffer implements IActionBuffer {
	static var instance: NullActionBuffer;

	public static function getInstance() {
		if (instance == null)
			instance = new NullActionBuffer();

		return instance;
	}

	public var latestAction(default, null): ActionSnapshot;

	function new() {
		latestAction = new ActionSnapshot();
	}

	public function update() {}
}

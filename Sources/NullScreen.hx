import kha.graphics2.Graphics;
import Screen.IScreen;

final class NullScreen implements IScreen {
	public static var instance(get, null): NullScreen;

	static function get_instance() {
		if (instance == null)
			instance = new NullScreen();

		return instance;
	}

	function new() {}

	public function update() {}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {}
}

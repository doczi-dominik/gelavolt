import kha.graphics2.Graphics;
import Screen.IScreen;

final class NullScreen implements IScreen {
	static var instance: NullScreen;

	public static function getInstance() {
		if (instance == null)
			instance = new NullScreen();

		return instance;
	}

	function new() {}

	public function update() {}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {}
}

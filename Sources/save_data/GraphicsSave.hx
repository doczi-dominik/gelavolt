package save_data;

class GraphicsSave {
	public var fullscreen: Null<Bool>;

	public function new() {}

	public function setDefaults() {
		if (fullscreen == null)
			fullscreen = true;
	}
}

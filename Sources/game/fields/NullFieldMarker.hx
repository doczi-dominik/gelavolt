package game.fields;

import kha.graphics2.Graphics;

class NullFieldMarker implements IFieldMarker {
	static var instance: NullFieldMarker;

	public static function getInstance() {
		if (instance == null)
			instance = new NullFieldMarker();

		return instance;
	}

	public final type: FieldMarkerType;

	function new() {
		type = Null;
	}

	public function copy() {
		return instance;
	}

	public function onSet(value: IFieldMarker) {
		return value;
	}

	public function render(g: Graphics, x: Float, y: Float) {}
}

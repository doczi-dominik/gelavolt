package game.fields;

import kha.graphics2.Graphics;

class NullFieldMarker implements IFieldMarker {
	public static final instance = new NullFieldMarker();

	public final type: FieldMarkerType;

	function new() {
		type = Null;
	}

	public function copy(): Dynamic {
		return instance;
	}

	public function onSet(value: IFieldMarker) {
		return value;
	}

	public function render(g: Graphics, x: Float, y: Float) {}
}

package game.fields;

import kha.graphics2.Graphics;

interface IFieldMarker {
	public final type: FieldMarkerType;

	public function copy(): IFieldMarker;

	public function onSet(value: IFieldMarker): IFieldMarker;

	public function render(g: Graphics, x: Float, y: Float): Void;
}

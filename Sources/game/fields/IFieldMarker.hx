package game.fields;

import game.copying.ICopy;
import kha.graphics2.Graphics;

interface IFieldMarker extends ICopy {
	public final type: FieldMarkerType;

	public function onSet(value: IFieldMarker): IFieldMarker;

	public function render(g: Graphics, x: Float, y: Float): Void;
}

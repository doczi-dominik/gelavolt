package game.gelos;

import game.copying.ICopy;
import utils.IntPoint;

@:structInit
class GeloPoint extends IntPoint implements ICopy {
	public final color: GeloColor;

	public function copy() {
		return ({
			x: x,
			y: y,
			color: color
		} : GeloPoint);
	}
}

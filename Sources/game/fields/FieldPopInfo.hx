package game.fields;

import game.gelos.GeloPoint;
import game.gelos.GeloColor;

class FieldPopInfo {
	public final beginners: Array<GeloPoint> = [];
	public final clears: Array<GeloPoint> = [];
	public final clearsByColor: Map<GeloColor, Int> = [COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0];

	public var hasPops: Bool;

	public function new() {}

	public function addClear(color: GeloColor, x: Int, y: Int) {
		clears.push({color: color, x: x, y: y});
		clearsByColor[color]++;
	}
}

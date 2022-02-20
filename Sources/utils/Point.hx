package utils;

@:structInit
class Point {
	public final x: Float;
	public final y: Float;

	public function add(rhs: Point): Point {
		return {x: x + rhs.x, y: y + rhs.y};
	}
}

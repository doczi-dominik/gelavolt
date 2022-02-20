package utils;

@:structInit
class IntPoint {
	public final x: Int;
	public final y: Int;

	public function sub(rhs: IntPoint): IntPoint {
		return {x: x - rhs.x, y: y - rhs.y};
	}
}

package input;

@:structInit
class AxisMapping {
	public final axis: Int;
	public final direction: Int;

	public function hashCode() {
		return (axis << 4) + direction;
	}
}

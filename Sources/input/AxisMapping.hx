package input;

@:structInit
class AxisMapping {
	public static function fromString(str: String): AxisMapping {
		final parts = str.split(";");

		return {
			axis: Std.parseInt(parts[0]),
			direction: Std.parseInt(parts[1])
		};
	}

	public final axis: Int;
	public final direction: Int;

	public function hashCode() {
		return (axis << 4) + direction;
	}

	public function isNotEqual(other: AxisMapping) {
		return axis != other.axis || direction != other.direction;
	}

	public function asString() {
		return '$axis;$direction';
	}
}

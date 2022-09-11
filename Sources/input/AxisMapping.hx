package input;

@:structInit
class AxisMapping implements hxbit.Serializable {
	public static function fromString(str: String): AxisMapping {
		final parts = str.split(";");

		return {
			axis: Std.parseInt(parts[0]),
			direction: Std.parseInt(parts[1])
		};
	}

	@:s public var axis(default, null): Null<Int>;
	@:s public var direction(default, null): Null<Int>;

	public function hashCode() {
		return (axis << 4) + direction;
	}

	public function isNotEqual(other: AxisMapping) {
		return axis != other.axis || direction != other.direction;
	}

	public inline function isNull() {
		return axis == null && direction == null;
	}

	public function asString() {
		return '$axis;$direction';
	}
}

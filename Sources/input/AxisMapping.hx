package input;

// Disabled due to issues with Serializable
// Null safety features still used in methods
@:nullSafety(Off)
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

	public function hashCode(): Null<Int> {
		if (axis == null || direction == null)
			return null;

		return (axis << 4) + direction;
	}

	public function isNotEqual(other: AxisMapping) {
		return axis != other.axis || direction != other.direction;
	}

	public inline function isNull() {
		return axis == null && direction == null;
	}
}

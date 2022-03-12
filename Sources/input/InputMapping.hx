package input;

import input.AxisMapping;
import kha.input.KeyCode;

@:structInit
class InputMapping {
	public static function fromString(str: String): InputMapping {
		final parts = str.split(";");

		return {
			keyboardInput: cast(Std.parseInt(parts[0]), KeyCode),
			gamepadButton: Std.parseInt(parts[1]),
			gamepadAxis: (parts[2] == null) ? null : AxisMapping.fromString(parts[2])
		};
	}

	public final keyboardInput: KeyCode;
	public final gamepadButton: GamepadButton;
	public final gamepadAxis: Null<AxisMapping>;

	public function isNotEqual(other: InputMapping) {
		var isAxisNotEqual: Bool;

		if (gamepadAxis == null && other.gamepadAxis == null) {
			isAxisNotEqual = false;
		} else if (gamepadAxis != null && other.gamepadAxis != null) {
			isAxisNotEqual = gamepadAxis.isNotEqual(other.gamepadAxis);
		} else {
			isAxisNotEqual = true;
		}

		return keyboardInput != other.keyboardInput || gamepadButton != other.gamepadButton || isAxisNotEqual;
	}

	public function asString() {
		return '$keyboardInput;$gamepadButton${gamepadAxis == null ? '' : ';gamepadAxis.asString()'}';
	}
}

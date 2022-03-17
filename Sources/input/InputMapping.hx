package input;

import input.AxisMapping;
import kha.input.KeyCode;

@:structInit
class InputMapping {
	public static function fromString(str: String): InputMapping {
		final parts = str.split(";");

		return {
			keyboardInput: (parts[0] != "") ? cast(Std.parseInt(parts[0]), KeyCode) : null,
			gamepadButton: (parts[1] != "") ? Std.parseInt(parts[1]) : null,
			gamepadAxis: (parts[2] != "") ? AxisMapping.fromString(parts[2]) : null
		};
	}

	public final keyboardInput: Null<KeyCode>;
	public final gamepadButton: Null<GamepadButton>;
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
		final kb = keyboardInput == null ? '' : '$keyboardInput';
		final bt = gamepadButton == null ? '' : '$gamepadButton';
		final ax = gamepadAxis == null ? '' : '$gamepadAxis';

		return '$kb;$bt;$ax';
	}
}

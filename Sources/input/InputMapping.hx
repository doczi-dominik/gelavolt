package input;

import input.AxisMapping;
import kha.input.KeyCode;

@:structInit
class InputMapping implements hxbit.Serializable {
	public static function fromString(str: String): InputMapping {
		final parts = str.split(";");

		return {
			keyboardInput: (parts[0] != "") ? cast(Std.parseInt(parts[0]), KeyCode) : null,
			gamepadButton: (parts[1] != "") ? Std.parseInt(parts[1]) : null,
			gamepadAxis: (parts[2] != "") ? AxisMapping.fromString(parts[2]) : {
				axis: null,
				direction: null
			}
		};
	}

	@:s public var keyboardInput(default, null): Null<KeyCode>;
	@:s public var gamepadButton(default, null): Null<GamepadButton>;
	@:s public var gamepadAxis(default, null): AxisMapping;

	public function isNotEqual(other: InputMapping) {
		return keyboardInput != other.keyboardInput || gamepadButton != other.gamepadButton || gamepadAxis.isNotEqual(other.gamepadAxis);
	}

	public function asString() {
		final kb = keyboardInput == null ? '' : '$keyboardInput';
		final bt = gamepadButton == null ? '' : '$gamepadButton';
		final ax = gamepadAxis == null ? '' : '${gamepadAxis.asString()}';

		return '$kb;$bt;$ax';
	}
}

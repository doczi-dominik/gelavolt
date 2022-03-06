package ui;

import input.GamepadInputDevice;
import input.KeyboardInputDevice;

@:structInit
class AnyGamepadDetectWrapperOptions {
	public final keyboardDevice: KeyboardInputDevice;
	public final pageBuilder: GamepadInputDevice->IMenuPage;
}

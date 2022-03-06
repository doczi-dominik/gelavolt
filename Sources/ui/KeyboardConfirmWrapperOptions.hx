package ui;

import input.KeyboardInputDevice;

@:structInit
class KeyboardConfirmWrapperOptions {
	public final keyboardDevice: KeyboardInputDevice;
	public final pageBuilder: Void->IMenuPage;
}

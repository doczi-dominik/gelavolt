package side_setup;

import kha.graphics2.Graphics;
import kha.Assets;
import input.IInputDevice;
import kha.Font;

class InputDeviceIcon {
	static inline final FONT_SIZE = 56;

	final font: Font;

	var fontSize: Int;
	var nameTextHalfWidth: Float;

	public final name: String;
	public final device: IInputDevice;

	public var height(default, null): Float;
	public var slot: InputSlot;

	public function new(name: String, device: IInputDevice) {
		font = Assets.fonts.Pixellari;

		this.name = name;
		this.device = device;

		slot = UNASSIGNED;
	}

	public inline function getLeftAction() {
		return device.getAction(MENU_LEFT);
	}

	public inline function getRightAction() {
		return device.getAction(MENU_RIGHT);
	}

	public inline function getControlsAction() {
		return device.getAction(MENU_UP);
	}

	public inline function getReadyAction() {
		return device.getAction(CONFIRM);
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.screen.smallerScale);
		nameTextHalfWidth = font.width(fontSize, name) / 2;

		height = font.height(fontSize);
	}

	public function render(g: Graphics, y: Float) {
		g.font = font;
		g.fontSize = fontSize;
		g.drawString(name, ScaleManager.screen.width / 4 * slot - nameTextHalfWidth, y);
	}
}

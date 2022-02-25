package versus_setup;

import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import input.InputDevice;
import input.InputDeviceManager;
import game.actions.MenuActions;

class InputManagerIcon {
	static inline final FONT_SIZE = 56;

	final font: Font;

	final device: InputDevice;
	final inputManager: InputDeviceManager;

	var fontSize: Int;
	var nameTextHalfWidth: Float;

	public final name: String;

	public var height(default, null): Float;

	public var slot: InputSlot;

	public function new(opts: InputManagerIconOptions) {
		font = Assets.fonts.Pixellari;

		device = opts.device;
		inputManager = opts.inputManager;

		name = opts.name;

		slot = UNASSIGNED;
	}

	public inline function getLeftAction() {
		return inputManager.getAction(LEFT);
	}

	public inline function getRightAction() {
		return inputManager.getAction(RIGHT);
	}

	public function resize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		nameTextHalfWidth = font.width(fontSize, name) / 2;

		height = font.height(fontSize);
	}

	public function render(g: Graphics, y: Float) {
		g.font = font;
		g.fontSize = fontSize;
		g.drawString(name, ScaleManager.width / 4 * slot - nameTextHalfWidth, y);
	}
}

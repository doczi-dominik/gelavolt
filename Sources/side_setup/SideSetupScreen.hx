package side_setup;

import input.IInputDevice;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import Screen.IScreen;

class SideSetupScreen implements IScreen {
	static inline final FONT_SIZE = 80;
	static inline final LEFT_BOARD_STR = "Left Board";
	static inline final RIGHT_BOARD_STR = "Right Board";

	final font: Font;
	final onReady: (Null<IInputDevice>, Null<IInputDevice>) -> Void;

	var fontSize: Int;
	var leftBoardTextCenter: Float;
	var rightBoardTextCenter: Float;
	var leftSlot: Null<InputDeviceIcon>;
	var rightSlot: Null<InputDeviceIcon>;
	var devices: Array<InputDeviceIcon>;

	function new(onReady: (Null<IInputDevice>, Null<IInputDevice>) -> Void) {
		font = Assets.fonts.DigitalDisco;
		this.onReady = onReady;

		ScaleManager.addOnResizeCallback(onResize);
	}

	function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.screen.smallerScale);

		leftBoardTextCenter = font.width(fontSize, LEFT_BOARD_STR) / 2;
		rightBoardTextCenter = font.width(fontSize, RIGHT_BOARD_STR) / 2;

		for (d in devices) {
			d.onResize();
		}
	}

	inline function onLeft(d: InputDeviceIcon) {
		if (d.slot == UNASSIGNED && leftSlot == null) {
			d.slot = LEFT;
			leftSlot = d;

			return;
		}

		if (d.slot == RIGHT) {
			d.slot = UNASSIGNED;
			rightSlot = null;
		}
	}

	inline function onRight(d: InputDeviceIcon) {
		if (d.slot == UNASSIGNED && rightSlot == null) {
			d.slot = RIGHT;
			rightSlot = d;

			return;
		}

		if (d.slot == LEFT) {
			d.slot = UNASSIGNED;
			leftSlot = null;
		}
	}

	public function update() {
		for (d in devices) {
			if (d.getLeftAction()) {
				onLeft(d);
			} else if (d.getRightAction()) {
				onRight(d);
			}
		}
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		g.font = font;
		g.fontSize = fontSize;

		final quarterW = ScaleManager.screen.width / 4;
		final eightH = ScaleManager.screen.height / 8;

		g.drawString(LEFT_BOARD_STR, quarterW - leftBoardTextCenter, eightH);
		g.drawString(RIGHT_BOARD_STR, quarterW * 3 - rightBoardTextCenter, eightH);

		for (i in 0...devices.length) {
			final d = devices[i];

			if (d.slot == UNASSIGNED)
				d.render(g, eightH + (i + 2) * d.height);
		}

		if (leftSlot != null)
			leftSlot.render(g, eightH + leftSlot.height * 2);

		if (rightSlot != null)
			rightSlot.render(g, eightH + rightSlot.height * 2);
	}
}

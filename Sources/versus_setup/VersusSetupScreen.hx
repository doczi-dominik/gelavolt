package versus_setup;

import kha.Font;
import kha.Assets;
import input.InputMapping;
import save_data.InputSave;
import input.InputDeviceManager;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import Screen.IScreen;
import game.actions.MenuActions;
import game.actions.ActionCategory;

class VersusSetupScreen implements IScreen {
	static inline final HEADER_FONT_SIZE = 80;

	final headerFont: Font;

	final leftBoardString: String;
	final rightBoardString: String;

	final leftInputSave: InputSave;
	final rightInputSave: InputSave;

	final controllers: Array<InputManagerIcon>;

	var headerFontSize: Int;

	var leftBoardTextCenter: Float;
	var rightBoardTextCenter: Float;

	var leftSlot: Null<InputManagerIcon>;
	var rightSlot: Null<InputManagerIcon>;

	public function new() {
		headerFont = Assets.fonts.DigitalDisco;

		leftBoardString = "LEFT BOARD";
		rightBoardString = "RIGHT BOARD";

		leftInputSave = new InputSave();
		leftInputSave.setDefaults();

		final m = leftInputSave.mappings[MENU];

		m[LEFT] = ({keyboardInput: A, gamepadInput: DPAD_LEFT} : InputMapping);
		m[RIGHT] = ({keyboardInput: D, gamepadInput: DPAD_LEFT} : InputMapping);

		rightInputSave = new InputSave();
		rightInputSave.setDefaults();

		controllers = [
			new InputManagerIcon({
				name: "Keyboard (WASD)",
				device: KEYBOARD,
				inputManager: new InputDeviceManager(leftInputSave, null),
			}),
			new InputManagerIcon({
				name: "Keyboard (Arrow)",
				device: KEYBOARD,
				inputManager: new InputDeviceManager(rightInputSave, null),
			}),
		];

		ScaleManager.addOnResizeCallback(resize);

		leftSlot = null;
		rightSlot = null;
	}

	function resize() {
		headerFontSize = Std.int(HEADER_FONT_SIZE * ScaleManager.smallerScale);

		leftBoardTextCenter = headerFont.width(headerFontSize, leftBoardString) / 2;
		rightBoardTextCenter = headerFont.width(headerFontSize, rightBoardString) / 2;

		for (c in controllers) {
			c.resize();
		}
	}

	public function update() {
		for (c in controllers) {
			if (c.getLeftAction()) {
				if (c.slot == UNASSIGNED && leftSlot == null) {
					c.slot = LEFT;
					leftSlot = c;
				} else if (c.slot == RIGHT) {
					c.slot = UNASSIGNED;
					rightSlot = null;
				}
			} else if (c.getRightAction()) {
				if (c.slot == UNASSIGNED && rightSlot == null) {
					c.slot = RIGHT;
					rightSlot = c;
				} else if (c.slot == LEFT) {
					c.slot = UNASSIGNED;
					leftSlot = null;
				}
			}
		}
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		g.font = headerFont;
		g.fontSize = headerFontSize;

		final quarterW = ScaleManager.width / 4;
		final eightH = ScaleManager.height / 8;

		g.drawString(leftBoardString, quarterW - leftBoardTextCenter, eightH);
		g.drawString(rightBoardString, quarterW * 3 - rightBoardTextCenter, eightH);

		for (i in 0...controllers.length) {
			final c = controllers[i];

			if (c.slot == UNASSIGNED)
				c.render(g, eightH + (i + 2) * c.height);
		}

		if (leftSlot != null)
			leftSlot.render(g, eightH + leftSlot.height * 2);
		if (rightSlot != null)
			rightSlot.render(g, eightH + rightSlot.height * 2);
	}
}

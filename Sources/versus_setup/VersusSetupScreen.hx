package versus_setup;

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
	final leftInputSave = new InputSave();
	final rightInputSave = new InputSave();
	final controllers: Array<InputManagerIcon>;

	final unassigned: InputSlot;
	final leftSlot: InputSlot;
	final rightSlot: InputSlot;

	public function new() {
		leftInputSave = new InputSave();
		leftInputSave.setDefaults();

		final m = leftInputSave.mappings[MENU];

		m[LEFT] = ({keyboardInput: A, gamepadInput: DPAD_LEFT} : InputMapping);
		m[RIGHT] = ({keyboardInput: D, gamepadInput: DPAD_LEFT} : InputMapping);

		rightInputSave = new InputSave();
		rightInputSave.setDefaults();

		unassigned = new InputSlot(10);
		leftSlot = new InputSlot(1);
		rightSlot = new InputSlot(1);

		controllers = [
			new InputManagerIcon({
				name: "Keyboard (WASD)",
				device: KEYBOARD,
				inputManager: new InputDeviceManager(leftInputSave, null),
				defaultSlot: unassigned
			}),
			new InputManagerIcon({
				name: "Keyboard (Arrow)",
				device: KEYBOARD,
				inputManager: new InputDeviceManager(rightInputSave, null),
				defaultSlot: unassigned
			}),
		];

		for (c in controllers) {
			unassigned.assign(c);
		}
	}

	public function update() {
		for (c in controllers) {
			if (c.getLeftAction()) {
				if (c.slot == rightSlot) {
					unassigned.assign(c);
				} else if (leftSlot.canAssign()) {
					leftSlot.assign(c);
				}
			} else if (c.getRightAction()) {
				if (c.slot == leftSlot) {
					unassigned.assign(c);
				} else if (rightSlot.canAssign()) {
					rightSlot.assign(c);
				}
			}
		}
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		g.font = Assets.fonts.Pixellari;
		g.fontSize = 64;

		leftSlot.render(g, 0);
		unassigned.render(g, 640);
		rightSlot.render(g, 1280);
	}
}

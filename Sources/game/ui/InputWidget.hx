package game.ui;

import game.actions.ActionTitles.ACTION_TITLES;
import input.InputDeviceManager;
import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import input.KeyCodeToString.KEY_CODE_TO_STRING;
import ui.ControlDisplay;
import game.actions.Action;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.IListWidget;

class InputWidget implements IListWidget {
	final menu: Menu;

	public final action: Action;

	public var description(default, null): Array<String> = [];
	public var controlDisplays: Array<ControlDisplay> = [{actions: [CONFIRM], description: "Rebind"}];

	public var isRebinding: Bool;

	public function new(menu: Menu, action: Action) {
		this.menu = menu;
		this.action = action;

		isRebinding = false;
	}

	public function onShow(menu: Menu) {}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;

		if (isRebinding) {
			g.drawString('Press any key / button for [ $action ]', x, y);
			g.color = White;

			return;
		}

		final inputManager = menu.inputManager;
		final mapping = inputManager.inputSettings.getMapping(action);

		final str = '${ACTION_TITLES[action]} : ${KEY_CODE_TO_STRING[mapping.keyboardInput]} / ';
		final w = g.font.width(g.fontSize, str);
		final h = g.font.height(g.fontSize);

		g.drawString(str, x, y);

		g.color = White;

		final spr = GAMEPAD_SPRITE_COORDINATES[mapping.gamepadInput];

		InputDeviceManager.renderGamepadIcon(g, x + w, y, spr, h / spr.height);
	}
}

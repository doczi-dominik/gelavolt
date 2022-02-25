package game.ui;

import input.KeyCodeToString.KEY_CODE_TO_STRING;
import kha.graphics2.Graphics;
import ui.ControlDisplay;
import game.actions.Action;
import game.actions.ActionCategory;
import ui.Menu;
import game.actions.MenuActions;

class KeyboardInputWidget implements IInputWidget {
	final menu: Menu;
	final category: ActionCategory;

	public final action: Action;

	public var description(default, null): Array<String> = [];
	public var controlDisplays: Array<ControlDisplay> = [{actions: [CONFIRM], description: "Rebind"}];

	public var isRebinding: Bool;

	public function new(menu: Menu, category: ActionCategory, action: Action) {
		this.menu = menu;
		this.category = category;
		this.action = action;

		isRebinding = false;
	}

	public function onShow(menu: Menu) {}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;

		if (isRebinding) {
			g.drawString('Press any key for [ $action ]', x, y);
		} else {
			final mapping = menu.inputManager.inputOptions.mappings[category][action];

			g.drawString('$action : ${KEY_CODE_TO_STRING[mapping.keyboardInput]}', x, y);
		}

		g.color = White;
	}
}

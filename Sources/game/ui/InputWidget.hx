package game.ui;

import game.actions.ActionCategory;
import game.actions.MenuActions;
import ui.ControlDisplay;
import game.actions.Action;
import input.InputDeviceManager;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.IListWidget;

class InputWidget implements IListWidget {
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
			g.drawString('Press any key / button for [ $action ]', x, y);
			g.color = White;

			return;
		}

		final inputManager = menu.inputManager;
		final mapping = inputManager.inputOptions.mappings[category][action];
		final kbInput = mapping.keyboardInput;
		final gpInput = mapping.gamepadInput;

		final str = '$action : ';
		final width = g.font.width(g.fontSize, str);

		g.drawString(str, x, y);

		g.color = White;

		final offsetX = x + width;
		final gpIconSize = 64 * ScaleManager.smallerScale;

		inputManager.renderGamepadIcon(g, offsetX, y, gpInput, gpIconSize);

		final kbString = InputDeviceManager.keyCodeToString[kbInput];

		g.drawString(' / $kbString', offsetX + gpIconSize, y);
	}
}

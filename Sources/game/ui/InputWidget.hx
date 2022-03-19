package game.ui;

import kha.Assets;
import kha.Font;
import game.actions.ActionData.ACTION_DATA;
import ui.ControlDisplay;
import game.actions.Action;
import kha.graphics2.Graphics;
import ui.Menu;
import ui.IListWidget;

class InputWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;
	final action: Action;

	var fontSize: Int;
	var menu: Menu;

	var unbindCounter: Int;
	var defaultCounter: Int;
	var isUnbindable: Bool;

	public var description(default, null): Array<String>;
	public var controlDisplays: Array<ControlDisplay> = [
		{actions: [CONFIRM], description: "Rebind"},
		{actions: [MENU_RIGHT], description: "Default (HOLD)"},
	];
	public var height(default, null): Float;

	public function new(action: Action) {
		font = Assets.fonts.Pixellari;
		this.action = action;

		final data = ACTION_DATA[action];

		isUnbindable = data.isUnbindable;

		if (isUnbindable)
			controlDisplays.push({actions: [MENU_LEFT], description: "Unbind (HOLD)"});

		description = data.description;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		final inputDevice = menu.inputDevice;

		if (isUnbindable && inputDevice.getRawAction(MENU_LEFT)) {
			++unbindCounter;
		} else {
			unbindCounter = 0;
		}

		if (inputDevice.getRawAction(MENU_RIGHT)) {
			++defaultCounter;
		} else {
			defaultCounter = 0;
		}

		if (unbindCounter == 90) {
			inputDevice.unbind(action);

			// Disallow other action
			unbindCounter = 100;
			defaultCounter = 100;
		}

		if (defaultCounter == 90) {
			inputDevice.bindDefault(action);

			// Disallow other action
			unbindCounter = 100;
			defaultCounter = 100;
		}

		if (inputDevice.getAction(CONFIRM)) {
			inputDevice.rebind(action);
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.font = font;
		g.fontSize = fontSize;
		menu.inputDevice.renderBinding(g, x, y, action);
		g.color = White;
	}
}

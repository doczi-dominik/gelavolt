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

	public var description(default, null): Array<String>;
	public var controlDisplays: Array<ControlDisplay> = [
		{actions: [MENU_LEFT], description: "Unbind"},
		{actions: [MENU_RIGHT], description: "Default"},
		{actions: [CONFIRM], description: "Rebind"}
	];
	public var height(default, null): Float;

	public function new(action: Action) {
		font = Assets.fonts.Pixellari;
		this.action = action;

		description = ACTION_DATA[action].description;
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

		if (inputDevice.getAction(MENU_LEFT)) {
			inputDevice.unbind(action);
		}

		if (inputDevice.getAction(MENU_RIGHT)) {
			inputDevice.bindDefault(action);
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

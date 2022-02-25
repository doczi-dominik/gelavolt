package game.ui;

import kha.Assets;
import kha.Font;
import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import kha.graphics2.Graphics;
import ui.ControlDisplay;
import game.actions.Action;
import game.actions.ActionCategory;
import ui.Menu;
import game.actions.MenuActions;

class GamepadInputWidget implements IInputWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;

	final menu: Menu;
	final category: ActionCategory;

	var fontSize: Int;

	public final action: Action;

	public var description(default, null): Array<String> = [];
	public var controlDisplays: Array<ControlDisplay> = [{actions: [CONFIRM], description: "Rebind"}];
	public var height(default, null): Float;

	public var isRebinding: Bool;

	public function new(menu: Menu, category: ActionCategory, action: Action) {
		font = Assets.fonts.Pixellari;

		this.menu = menu;
		this.category = category;
		this.action = action;

		isRebinding = false;
	}

	public function onShow(menu: Menu) {}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * ScaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.font = font;
		g.fontSize = fontSize;
		g.color = (isSelected) ? Orange : White;

		if (isRebinding) {
			g.drawString('Press any button for [ $action ]', x, y);
		} else {
			final inputManager = menu.inputManager;
			final mapping = inputManager.inputOptions.mappings[category][action];

			final str = '$action : ';

			g.drawString(str, x, y);

			final spr = GAMEPAD_SPRITE_COORDINATES[mapping.gamepadInput];

			inputManager.renderGamepadIcon(g, x + g.font.width(g.fontSize, str), y, spr, g.font.height(g.fontSize) / spr.height);
		}

		g.color = White;
	}
}

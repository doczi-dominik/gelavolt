package ui;

import kha.Font;
import kha.Assets;
import kha.graphics2.Graphics;
import utils.Utils.limitDecimals;

@:structInit
@:build(game.Macros.buildOptionsClass(NumberRangeWidget))
class NumberRangeWidgetOptions {}

class NumberRangeWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	@inject final title: String;
	@inject final minValue: Float;
	@inject final maxValue: Float;
	@inject final delta: Float;
	@inject final startValue: Float;
	@inject final onChange: Float->Void;

	@inject public var description(default, null): Array<String>;

	final font: Font;

	var fontSize = 0;

	var menu: Null<Menu>;
	var value: Float;

	public var controlHints(default, null): Array<ControlHint> = [{actions: [MENU_LEFT, MENU_RIGHT], description: "Change"}];
	public var height(default, null) = 0.0;

	public function new(opts: NumberRangeWidgetOptions) {
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		value = limitDecimals(startValue, 2);
	}

	inline function setValue(v: Float) {
		value = limitDecimals(v, 2);
		onChange(v);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		if (menu == null)
			return;

		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
		if (menu == null)
			return;

		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(MENU_LEFT)) {
			final nextValue = value - delta;

			if (nextValue < minValue) {
				setValue(maxValue);
			} else {
				setValue(nextValue);
			}
		} else if (inputDevice.getAction(MENU_RIGHT)) {
			final nextValue = value + delta;

			if (nextValue > maxValue) {
				setValue(minValue);
			} else {
				setValue(nextValue);
			}
		}
	}

	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool) {
		g.color = (isSelected) ? Orange : White;
		g.font = font;
		g.fontSize = fontSize;
		g.drawString('$title: < $value >', x, y);
		g.color = White;
	}
}

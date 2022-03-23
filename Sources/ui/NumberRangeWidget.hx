package ui;

import kha.Font;
import kha.Assets;
import kha.graphics2.Graphics;
import utils.Utils.limitDecimals;

class NumberRangeWidget implements IListWidget {
	static inline final FONT_SIZE = 60;

	final font: Font;

	final title: String;
	final minValue: Float;
	final maxValue: Float;
	final delta: Float;
	final onChange: Float->Void;

	var fontSize: Int;

	var menu: Menu;
	var value: Float;

	public var description(default, null): Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [MENU_LEFT, MENU_RIGHT], description: "Change"}];
	public var height(default, null): Float;

	public function new(opts: NumericalRangeWidgetOptions) {
		font = Assets.fonts.Pixellari;

		title = opts.title;
		minValue = opts.minValue;
		maxValue = opts.maxValue;
		delta = opts.delta;
		onChange = opts.onChange;

		value = limitDecimals(opts.startValue, 2);

		description = opts.description;
	}

	inline function setValue(v: Float) {
		value = limitDecimals(v, 2);
		onChange(v);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		height = font.height(fontSize);
	}

	public function update() {
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

package ui;

import kha.graphics2.Graphics;
import utils.Utils.limitDecimals;

class NumberRangeWidget implements IListWidget {
	final title: String;
	final minValue: Float;
	final maxValue: Float;
	final delta: Float;
	final onChange: Float->Void;

	var menu: Menu;
	var value(default, null): Float;

	public var description(default, null): Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay> = [{actions: [LEFT, RIGHT], description: "Change Value"}];

	public function new(opts: NumericalRangeWidgetOptions) {
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

	public function update() {
		final inputManager = menu.inputManager;

		if (inputManager.getAction(LEFT)) {
			final nextValue = value - delta;

			if (nextValue < minValue) {
				setValue(maxValue);
			} else {
				setValue(nextValue);
			}
		} else if (inputManager.getAction(RIGHT)) {
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
		g.drawString('$title: < $value >', x, y);
		g.color = White;
	}
}

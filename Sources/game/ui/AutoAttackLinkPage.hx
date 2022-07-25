package game.ui;

import game.auto_attack.AutoAttackLinkData;
import game.auto_attack.AutoAttackManager;
import ui.IListWidget;
import ui.YesNoWidget;
import game.gelos.GeloColor;
import ui.NumberRangeWidget;
import ui.ListMenuPage;

class AutoAttackLinkPage extends ListMenuPage {
	final autoAttackManager: AutoAttackManager;
	final data: AutoAttackLinkData;

	public function new(autoAttackManager: AutoAttackManager, data: AutoAttackLinkData) {
		this.autoAttackManager = autoAttackManager;
		this.data = data;

		super({
			header: "Edit Link",
			widgetBuilder: (_) -> {
				final widgets: Array<IListWidget> = [
					new NumberRangeWidget({
						title: "Clears For Color 1",
						description: ["Set The Number Of Color 1 Gelos", "That Popped In The Link"],
						minValue: 0,
						maxValue: 72,
						startValue: getColor(COLOR1),
						delta: 1,
						onChange: (value) -> {
							setColor(COLOR1, value);
						}
					}),
					new NumberRangeWidget({
						title: "Clears For Color 2",
						description: ["Set The Number Of Color 2 Gelos", "That Popped In The Link"],
						minValue: 0,
						maxValue: 72,
						startValue: getColor(COLOR2),
						delta: 1,
						onChange: (value) -> {
							setColor(COLOR2, value);
						}
					}),
					new NumberRangeWidget({
						title: "Clears For Color 3",
						description: ["Set The Number Of Color 3 Gelos", "That Popped In The Link"],
						minValue: 0,
						maxValue: 72,
						startValue: getColor(COLOR3),
						delta: 1,
						onChange: (value) -> {
							setColor(COLOR3, value);
						}
					}),
					new NumberRangeWidget({
						title: "Clears For Color 4",
						description: ["Set The Number Of Color 4 Gelos", "That Popped In The Link"],
						minValue: 0,
						maxValue: 72,
						startValue: getColor(COLOR4),
						delta: 1,
						onChange: (value) -> {
							setColor(COLOR4, value);
						}
					}),
					new NumberRangeWidget({
						title: "Clears For Color 5",
						description: ["Set The Number Of Color 5 Gelos", "That Popped In The Link"],
						minValue: 0,
						maxValue: 72,
						startValue: getColor(COLOR5),
						delta: 1,
						onChange: (value) -> {
							setColor(COLOR5, value);
						}
					}),
				];

				if (data == autoAttackManager.linkData.data[0]) {
					widgets.push(new YesNoWidget({
						title: "Send All Clear Bonus",
						description: ["Whether To Send All Clear Bonus On This Link"],
						defaultValue: false,
						onChange: (value) -> {
							data.sendsAllClearBonus = value;

							autoAttackManager.constructLinks();
						}
					}));
				}

				return widgets;
			}
		});
	}

	inline function getColor(color: GeloColor) {
		return data.clearsByColor[color];
	}

	function setColor(color: GeloColor, value: Float) {
		data.clearsByColor[color] = Std.int(value);

		autoAttackManager.constructLinks();
	}
}

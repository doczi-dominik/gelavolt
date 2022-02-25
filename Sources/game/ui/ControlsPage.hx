package game.ui;

import ui.IListWidget;
import game.actions.OrderedCategoryKeys;
import game.actions.ActionCategory;
import save_data.SaveManager;
import game.actions.MenuActions;
import ui.ListMenuPage;

class ControlsPage extends ListMenuPage {
	final category: ActionCategory;

	public function new(category: ActionCategory) {
		super({
			header: category,
			widgetBuilder: (menu) -> {
				final widgets: Array<IListWidget> = [];

				for (k in OrderedCategoryKeys[category]) {
					final w = (menu.inputManager.isGamepad) ? new GamepadInputWidget(menu, category, k) : new KeyboardInputWidget(menu, category, k);

					widgets.push(w);
				}

				return widgets;
			}
		});

		controlDisplays = [
			{actions: [UP, DOWN], description: "Select List Entry"},
			{actions: [BACK], description: "Back"},
			{actions: [CONFIRM], description: "Rebind"}
		];

		this.category = category;
	}

	override function update() {
		super.update();

		final inputManager = menu.inputManager;

		final currentWidget = cast(widgets[widgetIndex], IInputWidget);

		if (inputManager.getAction(CONFIRM)) {
			inputManager.rebind(currentWidget.action, category);
		}

		if (currentWidget.isRebinding && !inputManager.isRebinding) {
			SaveManager.saveProfiles();
		}

		currentWidget.isRebinding = inputManager.isRebinding;
	}
}

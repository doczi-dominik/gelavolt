package game.ui;

import game.actions.Action;
import ui.IListWidget;
import save_data.SaveManager;
import ui.ListMenuPage;

class ControlsPage extends ListMenuPage {
	public function new(header: String, actions: Array<Action>) {
		super({
			header: header,
			widgetBuilder: (menu) -> actions.map((action) -> (new InputWidget(menu, action) : IListWidget))
		});

		controlDisplays = [
			{actions: [UP, DOWN], description: "Select List Entry"},
			{actions: [BACK], description: "Back"},
			{actions: [CONFIRM], description: "Rebind"}
		];
	}

	override function update() {
		super.update();

		final inputManager = menu.inputManager;

		final currentWidget = cast(widgets[widgetIndex], InputWidget);

		if (inputManager.getAction(CONFIRM)) {
			inputManager.rebind(currentWidget.action);
		}

		if (currentWidget.isRebinding && !inputManager.isRebinding) {
			SaveManager.saveProfiles();
		}

		currentWidget.isRebinding = inputManager.isRebinding;
	}
}

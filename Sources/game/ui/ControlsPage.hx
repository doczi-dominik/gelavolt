package game.ui;

import game.actions.Action;
import ui.IListWidget;
import save_data.SaveManager;
import ui.ListMenuPage;

class ControlsPage extends ListMenuPage {
	public function new(header: String, actions: Array<Action>) {
		super({
			header: header,
			widgetBuilder: (menu) -> actions.map((action) -> (new InputWidget({
				action: action,
				inputDevice: menu.inputDevice
			}) : IListWidget))
		});

		controlDisplays = [
			{actions: [UP, DOWN], description: "Select List Entry"},
			{actions: [BACK], description: "Back"},
			{actions: [CONFIRM], description: "Rebind"}
		];
	}

	override function update() {
		super.update();

		final inputDevice = menu.inputDevice;

		final currentWidget = cast(widgets[widgetIndex], InputWidget);

		if (inputDevice.getAction(CONFIRM)) {
			inputDevice.rebind(currentWidget.action);
		}

		if (currentWidget.isRebinding && !inputDevice.isRebinding) {
			SaveManager.saveProfiles();
		}

		currentWidget.isRebinding = inputDevice.isRebinding;
	}
}

package game.ui;

import game.actions.ActionCategory;
import ui.SubPageWidget;

class ControlsPageWidget extends SubPageWidget {
	public function new(category: ActionCategory) {
		super({
			title: category,
			description: [""],
			subPage: new ControlsPage(category),
		});
	}
}

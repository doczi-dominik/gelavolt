package game.ui;

import ui.SubPageWidget;

class ControlsPageWidget extends SubPageWidget {
	public function new(opts: ControlsPageWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			subPage: new ControlsPage({
				header: opts.title,
				actions: opts.actions,
				inputDevice: opts.inputDevice
			})
		});
	}
}

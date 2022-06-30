package game.ui;

import input.IInputDevice;
import game.actions.Action;
import ui.SubPageWidget;

@:structInit
class ControlsPageWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final actions: Array<Action>;
	public final inputDevice: IInputDevice;
}

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

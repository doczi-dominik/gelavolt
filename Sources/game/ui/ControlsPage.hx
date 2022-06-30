package game.ui;

import input.IInputDevice;
import game.actions.Action;
import ui.InputLimitedListPage;
import ui.IListWidget;

@:structInit
class ControlsPageOptions {
	public final header: String;
	public final actions: Array<Action>;
	public final inputDevice: IInputDevice;
}

class ControlsPage extends InputLimitedListPage {
	public function new(opts: ControlsPageOptions) {
		super({
			header: opts.header,
			widgetBuilder: (menu) -> opts.actions.map((action) -> (new InputWidget(action) : IListWidget)),
			inputDevice: opts.inputDevice
		});
	}
}

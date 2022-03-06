package ui;

import ui.InputLimitedPageWidgetOptions;

class InputLimitedPageWidget extends SubPageWidget {
	public function new(opts: InputLimitedPageWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			subPage: new InputLimitedListPage({
				header: opts.title,
				widgetBuilder: opts.widgetBuilder,
				inputDevice: opts.inputDevice
			})
		});
	}
}

package ui;

import ui.ButtonWidget.ButtonWidgetOptions;

@:structInit
class AreYouSureSubPageWidgetOptions extends ButtonWidgetOptions {
	public final content: String;
}

class AreYouSureSubPageWidget extends SubPageWidget {
	public function new(opts: AreYouSureSubPageWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			subPage: new AreYouSurePage(opts.content, opts.callback)
		});
	}
}

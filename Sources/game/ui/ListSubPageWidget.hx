package game.ui;

import ui.ListMenuPage;
import ui.SubPageWidget;

class ListSubPageWidget extends SubPageWidget {
	public function new(opts: ListSubPageWidgetOptions) {
		super({
			title: opts.header,
			description: opts.description,
			subPage: new ListMenuPage({
				header: opts.header,
				widgetBuilder: opts.widgetBuilder
			})
		});
	}
}

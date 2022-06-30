package game.ui;

import ui.Menu;
import ui.IListWidget;
import ui.ListMenuPage;
import ui.SubPageWidget;

@:structInit
class ListSubPageWidgetOptions {
	public final header: String;
	public final description: Array<String>;
	public final widgetBuilder: Menu->Array<IListWidget>;
}

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

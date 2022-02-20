package game.ui;

import ui.Menu;
import ui.IListWidget;

@:structInit
class ListSubPageWidgetOptions {
	public final header: String;
	public final description: Array<String>;
	public final widgetBuilder: Menu->Array<IListWidget>;
}

package ui;

import input.IInputDevice;

@:structInit
class InputLimitedPageWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final widgetBuilder: Menu->Array<IListWidget>;
	public final inputDevice: IInputDevice;
}

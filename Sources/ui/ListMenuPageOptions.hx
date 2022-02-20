package ui;

@:structInit
class ListMenuPageOptions {
	public final header: String;
	public final widgetBuilder: Menu->Array<IListWidget>;
}

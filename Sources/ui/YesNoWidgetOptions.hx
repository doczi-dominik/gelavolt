package ui;

@:structInit
class YesNoWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final defaultValue: Bool;
	public final onChange: Bool->Void;
}

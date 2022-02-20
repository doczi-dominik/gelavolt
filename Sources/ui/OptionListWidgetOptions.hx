package ui;

@:structInit
class OptionListWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final options: Array<String>;
	public final startIndex: Int;
	public final onChange: String->Void;
}

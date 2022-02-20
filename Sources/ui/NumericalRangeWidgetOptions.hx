package ui;

@:structInit
class NumericalRangeWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final minValue: Float;
	public final maxValue: Float;
	public final delta: Float;
	public final startValue: Float;
	public final onChange: Float->Void;
}

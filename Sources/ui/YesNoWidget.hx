package ui;

@:structInit
class YesNoWidgetOptions {
	public final title: String;
	public final description: Array<String>;
	public final defaultValue: Bool;
	public final onChange: Bool->Void;
}

class YesNoWidget extends OptionListWidget {
	public function new(opts: YesNoWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			options: ["YES", "NO"],
			startIndex: opts.defaultValue ? 0 : 1,
			onChange: (value) -> {
				opts.onChange(value == "YES");
			}
		});
	}
}

package ui;

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

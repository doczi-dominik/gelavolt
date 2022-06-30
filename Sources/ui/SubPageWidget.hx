package ui;

@:structInit
class SubPageWidgetOptions {
	public final title: String;
	public final subPage: IMenuPage;

	public final description: Array<String>;
}

class SubPageWidget extends ButtonWidget {
	final subPage: IMenuPage;

	public function new(opts: SubPageWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			callback: pushSubPage
		});

		subPage = opts.subPage;
	}

	function pushSubPage() {
		menu.pushPage(subPage);
	}
}

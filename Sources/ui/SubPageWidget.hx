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
		subPage = opts.subPage;

		super({
			title: opts.title,
			description: opts.description,
			callback: pushSubPage
		});
	}

	function pushSubPage() {
		menu!.pushPage(subPage);
	}
}

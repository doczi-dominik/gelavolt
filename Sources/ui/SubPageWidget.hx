package ui;

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

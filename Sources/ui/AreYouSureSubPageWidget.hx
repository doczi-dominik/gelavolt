package ui;

class AreYouSureSubPageWidget extends SubPageWidget {
	public function new(opts: AreYouSureSubPageWidgetOptions) {
		super({
			title: opts.title,
			description: opts.description,
			subPage: new AreYouSurePage(opts.content, opts.callback)
		});
	}
}

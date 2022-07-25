package game.ui;

import game.auto_attack.AutoAttackLinkData;
import game.auto_attack.AutoAttackManager;
import game.simulation.ILinkInfoBuilder;
import ui.SubPageWidget;
import ui.IListWidget;
import ui.ButtonWidget;
import ui.ListMenuPage;

class CustomAutoAttackPage extends ListMenuPage {
	final autoAttackManager: AutoAttackManager;
	final linkBuilder: ILinkInfoBuilder;

	public function new(autoAttackManager: AutoAttackManager, linkBuilder: ILinkInfoBuilder) {
		this.autoAttackManager = autoAttackManager;
		this.linkBuilder = linkBuilder;

		super({
			header: "Configure",
			widgetBuilder: (_) -> {
				final data = autoAttackManager.linkData.data;

				final widgets: Array<IListWidget> = [
					new ButtonWidget({
						title: "Add Link",
						description: ["Add A New Chain Link"],
						callback: () -> {
							data.push(new AutoAttackLinkData());

							rebuild();
						}
					}),
					new ButtonWidget({
						title: "Clear Links",
						description: ["Delete All Chain Links"],
						callback: () -> {
							data.resize(0);

							rebuild();
						}
					})
				];

				for (i in 0...data.length) {
					final title = 'Link ${i + 1}';

					widgets.push(new SubPageWidget({
						title: title,
						description: ['Edit $title'],
						subPage: new AutoAttackLinkPage(autoAttackManager, data[i])
					}));
				}

				return widgets;
			}
		});
	}

	function rebuild() {
		onShow(menu);
		onResize();
	}
}

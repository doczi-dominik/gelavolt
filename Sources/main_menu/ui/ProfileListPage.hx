package main_menu.ui;

import ui.SubPageWidget;
import ui.IListWidget;
import save_data.SaveManager;
import ui.ButtonWidget;
import ui.ListMenuPage;

class ProfileListPage extends ListMenuPage {
	public function new() {
		super({
			header: "Profiles",
			widgetBuilder: (_) -> {
				final widgets: Array<IListWidget> = [
					new ButtonWidget({
						title: "Create New",
						description: ["Create A New Profile"],
						callback: () -> {
							SaveManager.newProfile();
							rebuild();
						}
					})
				];

				for (p in SaveManager.profiles) {
					widgets.push(new SubPageWidget({
						title: p.name,
						description: ['Edit ${p.name} Or Set It As Primary'],
						subPage: new ProfilePage(this, p)
					}));
				}

				return widgets;
			}
		});
	}

	public inline function rebuild() {
		if (menu != null) {
			onShow(menu);
			onResize();
		}
	}
}

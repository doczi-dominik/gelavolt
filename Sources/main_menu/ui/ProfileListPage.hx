package main_menu.ui;

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
					widgets.push(new ProfileWidget(this, p));
				}

				return widgets;
			}
		});
	}

	public inline function rebuild() {
		onShow(menu);
		onResize();
	}
}

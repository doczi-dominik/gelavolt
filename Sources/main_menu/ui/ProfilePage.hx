package main_menu.ui;

import save_data.SaveManager;
import game.ui.ListSubPageWidget;
import ui.ButtonWidget;
import ui.IListWidget;
import save_data.Profile;
import ui.ListMenuPage;

class ProfilePage extends ListMenuPage {
	final listPage: ProfileListPage;

	public function new(listPage: ProfileListPage, profile: Profile) {
		this.listPage = listPage;

		super({
			header: profile.name,
			widgetBuilder: (_) -> {
				final widgets: Array<IListWidget> = [

					new ListSubPageWidget({
						header: "Reset To Default",
						description: ["Reset Various Aspects Of The Profile", "To Their Default Values"],
						widgetBuilder: (_) -> [
							new ButtonWidget({
								title: "Reset Input Settings",
								description: ["Reset Input Settings"],
								callback: profile.setInputDefaults
							}),
							new ButtonWidget({
								title: "Reset Preferences",
								description: ["Reset Preferences"],
								callback: profile.setPrefsDefaults
							}),
							new ButtonWidget({
								title: "Reset Training Options",
								description: ["Reset Training Mode-Exclusive Options"],
								callback: profile.setTrainingDefaults
							}),
							new ButtonWidget({
								title: "Reset Endless Options",
								description: ["Reset Endless Mode-Exclusive Options"],
								callback: profile.setEndlessDefaults
							}),
							new ButtonWidget({
								title: "Reset All",
								description: ["Reset Input, Preferences, Training", "And Endless Options"],
								callback: profile.setDefaults
							})
						]
					}),
				];

				if (profile != Profile.primary) {
					widgets.unshift(new ButtonWidget({
						title: "Set As Primary",
						description: [
							"Set The Profile As Primary",
							"",
							"The Primary Profile Is Used For",
							"Menu Keybinds And Universal Match Preferences",
							"(Background Animation, Music, Etc.)"
						],
						callback: () -> {
							Profile.changePrimary(profile);
							// Rebuild Page
							onShow(menu);
							onResize();
						}
					}));

					widgets.push(new ButtonWidget({
						title: "Delete Profile",
						description: ["Permanently Delete This Profile"],
						callback: () -> {
							SaveManager.deleteProfile(profile);
							menu.popPage();
							listPage.rebuild();
						}
					}));
				}

				return widgets;
			}
		});
	}
}

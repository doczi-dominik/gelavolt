package main_menu.ui;

import ui.AreYouSureSubPageWidget;
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
							new AreYouSureSubPageWidget({
								title: "Reset Input Settings",
								description: ["Reset Input Settings"],
								content: "This Will IRREVERSIBLY Reset Your Input Settings",
								callback: () -> {
									profile.setInputDefaults();
									SaveManager.saveProfiles();
								}
							}),
							new AreYouSureSubPageWidget({
								title: "Reset Preferences",
								description: ["Reset Preferences"],
								content: "This Will IRREVERSIBLY Reset Your Preferences",
								callback: () -> {
									profile.setPrefsDefaults();
									SaveManager.saveProfiles();
								}
							}),
							new AreYouSureSubPageWidget({
								title: "Reset Training Options",
								description: ["Reset Training Mode-Exclusive Options"],
								content: "This Will IRREVERSIBLY Reset Your Training Options",
								callback: () -> {
									profile.setTrainingDefaults();
									SaveManager.saveProfiles();
								}
							}),
							new AreYouSureSubPageWidget({
								title: "Reset Endless Options",
								description: ["Reset Endless Mode-Exclusive Options"],
								content: "This Will IRREVERSIBLY Reset Your Endless Options",
								callback: () -> {
									profile.setEndlessDefaults();
									SaveManager.saveProfiles();
								}
							}),
							new AreYouSureSubPageWidget({
								title: "Reset All",
								description: ["Reset Input, Preferences, Training", "And Endless Options"],
								content: "This Will IRREVERSIBLY Reset All Of Your Data",
								callback: () -> {
									profile.setDefaults();
									SaveManager.saveProfiles();
								}
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

							if (menu != null) {
								onShow(menu);
								onResize();
							}
						}
					}));

					widgets.push(new ButtonWidget({
						title: "Delete Profile",
						description: ["Permanently Delete This Profile"],
						callback: () -> {
							SaveManager.deleteProfile(profile);
							menu!.popPage();
							listPage.rebuild();
						}
					}));
				}

				return widgets;
			}
		});
	}
}

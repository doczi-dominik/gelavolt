package main_menu.ui;

import save_data.Profile;
import ui.ButtonWidget;

class ProfileWidget extends ButtonWidget {
	public function new(page: ProfileListPage, profile: Profile) {
		super({
			title: '${profile.name}${profile == Profile.primary ? " (Primary)" : ""}',
			description: [],
			callback: () -> {
				Profile.changePrimary(profile);
				page.rebuild();
			}
		});
	}
}

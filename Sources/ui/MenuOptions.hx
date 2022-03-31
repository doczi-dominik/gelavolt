package ui;

import save_data.PrefsSettings;

@:structInit
class MenuOptions {
	public final prefsSettings: PrefsSettings;
	public final positionFactor: Float;
	public final widthFactor: Float;
	public final initialPage: IMenuPage;
}

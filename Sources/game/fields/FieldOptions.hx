package game.fields;

import save_data.PrefsSettings;

@:structInit
class FieldOptions {
	public final prefsSettings: PrefsSettings;
	public final columns: Int;
	public final playAreaRows: Int;
	public final hiddenRows: Int;
	public final garbageRows: Int;
}

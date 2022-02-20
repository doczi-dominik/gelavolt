package game.fields;

import save_data.PrefsSave;

@:structInit
class FieldOptions {
	public final prefsSave: PrefsSave;
	public final columns: Int;
	public final playAreaRows: Int;
	public final hiddenRows: Int;
	public final garbageRows: Int;
}

package game.fields;

enum abstract FieldMarkerType(Int) {
	final Null = 0;
	final Chain;
	final AllClear;
	final Dependency;
	final ColorConflict;
}

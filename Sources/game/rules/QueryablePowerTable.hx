package game.rules;

@:structInit
class QueryablePowerTable {
	final values: Array<Int>;
	final increment: Int;

	public function get(chain: Int) {
		final length = values.length;

		if (chain <= length)
			return values[chain - 1];

		final diff = chain - length;
		final extra = diff * increment;

		return values[length - 1] + extra;
	}
}

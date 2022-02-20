package game.rules;

import utils.Utils;
import haxe.ds.ReadOnlyArray;

abstract GroupBonusTable(Array<Int>) from Array<Int> to ReadOnlyArray<Int> {
	public function get(clears: Int) {
		final index = Utils.intClamp(0, clears - 1, this.length - 1);

		return this[index];
	}
}

package game;

import game.copying.ICopyFrom;
import game.copying.CopyableArray;
import game.gelogroups.GeloGroupData;
import utils.Utils;

class Queue implements ICopyFrom {
	@copy public final groups: CopyableArray<GeloGroupData>;

	@copy public var currentIndex(default, null): Int;

	public function new(groups: Array<GeloGroupData>) {
		this.groups = new CopyableArray([]);

		load(groups);
	}

	public inline function load(groups: Array<GeloGroupData>) {
		for (g in groups) {
			this.groups.data.push(g);
		}

		currentIndex = 0;
	}

	public function get(index: Int) {
		return groups.data[Std.int(Utils.negativeMod(index, groups.data.length))];
	}

	public function setIndex(index: Null<Int>) {
		if (index == null)
			return;

		currentIndex = index;
	}

	public inline function previous() {
		currentIndex--;
	}

	public inline function next() {
		currentIndex++;
	}

	public inline function getCurrent() {
		return get(currentIndex);
	}
}

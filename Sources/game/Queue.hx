package game;

import game.gelogroups.GeloGroupData;
import utils.Utils;
import haxe.ds.ReadOnlyArray;

class Queue {
	public var groups(default, null): ReadOnlyArray<GeloGroupData>;
	public var currentIndex(default, null): Int;

	public function new(groups: ReadOnlyArray<GeloGroupData>) {
		load(groups);
	}

	public inline function load(groups: ReadOnlyArray<GeloGroupData>) {
		this.groups = groups;

		currentIndex = 0;
	}

	public function get(index: Int) {
		return groups[Std.int(Utils.negativeMod(index, groups.length))];
	}

	public function setIndex(index: Int) {
		if (index == -1)
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

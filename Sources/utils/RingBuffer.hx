package utils;

import haxe.ds.ReadOnlyArray;

class RingBuffer<T> {
	final data: Array<T>;

	var index: Int;

	public final size: Int;

	public final values: ReadOnlyArray<T>;

	public function new(size: Int, defaultValue: T) {
		data = [for (_ in 0...size) defaultValue];

		index = 0;

		this.size = size;
		values = data;
	}

	public function add(x: T) {
		data[index] = x;

		index = (index + 1) % size;
	}

	public function get(i: Int) {
		return data[i];
	}

	public inline function getCurrent() {
		return get(index);
	}
}

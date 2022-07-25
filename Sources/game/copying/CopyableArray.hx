package game.copying;

class CopyableArray<T> implements ICopyFrom {
	public final data: Array<T>;

	public function new(data: Array<T>) {
		this.data = data;
	}

	public function copyFrom(other: Dynamic) {
		final o = (other : CopyableArray<T>);

		data.resize(0);

		for (d in o.data) {
			// data.push(d.copy());
		}

		return this;
	}

	public function copy() {
		return new CopyableArray<T>([]).copyFrom(this);
	}
}

package game.copying;

class CopyableArray<T:ICopy> implements ICopyFrom {
	public final data: Array<Null<T>>;

	public function new(data: Array<T>) {
		this.data = data;
	}

	public function copyFrom(other: Dynamic) {
		final o = (other : CopyableArray<T>);

		data.resize(0);

		for (d in o.data) {
			data.push(d == null ? null : d.copy());
		}

		return this;
	}
}

package game.copying;

class ConstantCopyableArray<T> implements ICopyFrom {
	public final data: Array<T>;

	public function new(data: Array<T>) {
		this.data = data;
	}

	public function copyFrom(other: Dynamic) {
		final o = (other : ConstantCopyableArray<T>);

		data.resize(0);

		for (d in o.data) {
			data.push(d);
		}

		return this;
	}

	public function copy(): Dynamic {
		return new ConstantCopyableArray(data.copy());
	}
}

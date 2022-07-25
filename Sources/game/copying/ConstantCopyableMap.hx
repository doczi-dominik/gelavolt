package game.copying;

class ConstantCopyableMap<T, U> implements ICopyFrom {
	public final data: Map<T, U>;

	public function new(data: Map<T, U>) {
		this.data = data;
	}

	public function copyFrom(other: Dynamic) {
		final o = (other : ConstantCopyableMap<T, U>);

		data.clear();

		for (k => v in o.data) {
			data[k] = v;
		}

		return this;
	}

	public function copy() {
		return new ConstantCopyableMap(data.copy());
	}
}

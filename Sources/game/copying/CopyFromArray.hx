package game.copying;

class CopyFromArray<T:ICopy> implements ICopyFrom {
	public final data: Array<T>;

	public function new(data: Array<T>) {
		this.data = data;
	}

	public function copyFrom(other: Dynamic) {}
}

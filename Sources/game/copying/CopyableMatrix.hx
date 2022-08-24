package game.copying;

class CopyableMatrix<T:ICopy & hxbit.Serializable> implements ICopyFrom implements hxbit.Serializable {
	public final data: Array<Array<T>>;

	public function new(height: Int) {
		data = [for (_ in 0...height) []];
	}

	public function copyFrom(other: Dynamic) {
		final o = (other : CopyableMatrix<T>);

		data.resize(0);

		for (y in 0...o.data.length) {
			data[y] = [];
			for (x in 0...o.data[y].length) {
				final obj = o.data[y][x];

				if (obj == null) {
					data[y][x] = null;
				} else {
					data[y][x] = obj.copy();
				}
			}
		}

		return this;
	}

	public function copy() {
		return new CopyableMatrix<T>(0).copyFrom(this);
	}

	@:keep
	public function customSerialize(ctx: hxbit.Serializer) {
		ctx.addArray(data, e -> {
			ctx.addArray(e, e -> {
				ctx.addAnyRef(e);
			});
		});
	}

	@:keep
	public function customUnserialize(ctx: hxbit.Serializer) {}
}

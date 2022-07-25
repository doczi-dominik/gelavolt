package game.copying;

import kha.math.Random;

@:access(kha.math.Random)
class CopyableRNG implements ICopyFrom {
	public final data: Random;

	public function new(seed: Int) {
		data = new Random(seed);
	}

	public function copyFrom(other: Dynamic) {
		final odata = other.data;

		data.a = odata.a;
		data.b = odata.b;
		data.c = odata.c;
		data.d = odata.d;
	}
}

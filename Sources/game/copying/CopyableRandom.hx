package game.copying;

import kha.math.Random;

@:access(kha.math.Random)
class CopyableRNG implements ICopyFrom {
	public final rng: Random;

	public function new(seed: Int) {
		rng = new Random(seed);
	}

	public function copyFrom(other: Dynamic) {
		final orng = other.rng;

		rng.a = orng.a;
		rng.b = orng.b;
		rng.c = orng.c;
		rng.d = orng.d;
	}
}

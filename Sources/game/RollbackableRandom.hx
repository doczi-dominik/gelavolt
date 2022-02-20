package game;

import kha.math.Random;

using game.RollbackableRandom;

@:access(kha.math.Random)
class RollbackableRandomExtension {
	public static function copyFrom(r: Random, src: Random) {
		r.a = src.a;
		r.b = src.b;
		r.c = src.c;
		r.d = src.d;
	}

	public static function copy(r: Random) {
		return new Random(0).copyFrom(r);
	}
}

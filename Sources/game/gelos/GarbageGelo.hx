package game.gelos;

import game.gelos.FieldGelo.FieldGeloOptions;

class GarbageGelo extends FieldGelo {
	public static function create(opts: FieldGeloOptions) {
		final p = new GarbageGelo(opts);

		init(p, opts);

		return p;
	}

	public static function init(p: GarbageGelo, opts: FieldGeloOptions) {
		FieldGelo.init(p, opts);
	}

	override function copy(): FieldGelo {
		return new GarbageGelo({
			prefsSettings: prefsSettings,
			color: color
		}).copyFrom(this);
	}

	override function startBouncing(type: GeloBounceType) {
		stopBouncing();
	}

	public function startGarbageFalling(accel: Float) {
		velocity = 0;
		velocityLimit = Gelo.HALFSIZE;
		this.accel = accel;
		distanceCounter = 0;
		state = FALLING;
	}
}

package game.gelos;

class GarbageGelo extends FieldGelo {
	public static function create(opts: FieldGeloOptions) {
		final p = new GarbageGelo(opts);

		init(p, opts);

		return p;
	}

	public static function init(p: GarbageGelo, opts: FieldGeloOptions) {
		FieldGelo.init(p, opts);
	}

	public static function copyTo(src: GarbageGelo, dest: GarbageGelo) {
		FieldGelo.copyTo(src, dest);
	}

	override function copyFrom(src: Gelo) {
		copyTo(cast(src, GarbageGelo), this);
	}

	override function copy(): FieldGelo {
		final p = new GarbageGelo({
			prefsSave: prefsSave,
			color: color
		});

		p.copyFrom(this);

		return p;
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

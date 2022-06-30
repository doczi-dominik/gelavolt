package game.gelos;

import game.gelos.Gelo.GeloOptions;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import utils.IntPoint;
import game.gelos.GeloPopType;

enum FieldGeloState {
	IDLE;
	FALLING;
	BOUNCING;
	POPPING;
}

@:structInit
class FieldGeloPoint extends IntPoint {
	public final gelo: FieldGelo;
}

@:structInit
@:build(game.Macros.buildOptionsClass(FieldGelo))
class FieldGeloOptions extends GeloOptions {}

@:allow(game.gelos.FieldGeloBuilder)
class FieldGelo extends Gelo {
	public static function create(opts: FieldGeloOptions) {
		final p = new FieldGelo(opts);

		init(p, opts);

		return p;
	}

	public static function init(p: FieldGelo, opts: FieldGeloOptions) {
		Gelo.init(p);

		p.x = opts.x;
		p.y = opts.y;

		p.state = IDLE;
	}

	public static function copyTo(src: FieldGelo, dest: FieldGelo) {
		Gelo.copyTo(src, dest);

		dest.x = src.x;
		dest.y = src.y;

		dest.distanceCounter = src.distanceCounter;
		dest.velocity = src.velocity;
		dest.velocityLimit = src.velocityLimit;
		dest.accel = src.accel;
		dest.state = src.state;
	}

	@inject public var x: Float;
	@inject public var y: Float;

	public var distanceCounter: Float;
	public var velocity: Float;
	public var velocityLimit(default, null): Float;
	public var accel(default, null): Float;
	public var state: FieldGeloState;

	override function copyFrom(src: Gelo) {
		copyTo(cast(src, FieldGelo), this);
	}

	override function copy() {
		final p = new FieldGelo({
			prefsSettings: prefsSettings,
			color: color
		});

		p.copyFrom(this);

		return p;
	}

	override function startBouncing(type: GeloBounceType) {
		super.startBouncing(type);
		state = BOUNCING;
	}

	override function stopBouncing() {
		super.stopBouncing();
		state = IDLE;
	}

	override function startPopping(type: GeloPopType) {
		super.startPopping(type);
		state = POPPING;
	}

	override function stopPopping() {
		super.stopPopping();
		state = IDLE;
	}

	public function startSplitting() {
		velocity = 0;
		velocityLimit = 23.25;
		accel = 0.75;
		// Hackerman way of achieving a TSU_SHORT bounce.
		distanceCounter = Gelo.HALFSIZE - 1;
		state = FALLING;
	}

	public function startDropping() {
		velocity = Gelo.HALFSIZE;
		velocityLimit = Gelo.HALFSIZE;
		accel = 0;
		distanceCounter = 0;
		state = FALLING;
	}

	public function stopFalling() {
		state = IDLE;
	}

	public function damage() {
		return true;
	}

	inline public function renderAtOwnPosition(g: Graphics, g4: Graphics4, alpha: Float) {
		render(g, g4, x, y, alpha);
	}
}

package game.gelos;

import main.Pipelines;
import game.copying.ICopy;
import save_data.PrefsSettings;
import utils.Point;
import utils.Utils.lerp;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import kha.Assets;
import game.gelos.GeloSpriteCoordinates;
import game.gelos.GeloBounceTables;

@:structInit
@:build(game.Macros.buildOptionsClass(Gelo))
class GeloOptions {}

class Gelo implements ICopy {
	public inline static final SIZE = 64;
	public inline static final HALFSIZE = 32;

	public static function renderStatic(g: Graphics, x: Float, y: Float, type: GeloColor, spriteVariation: GeloSpriteVariation) {
		final subImageCoords = GELO_SPRITE_COORDINATES[type][spriteVariation];

		if (subImageCoords == null)
			return;

		g.drawScaledSubImage(Assets.images.pixel, subImageCoords.x, subImageCoords.y, SIZE, SIZE, x - Gelo.HALFSIZE, y - Gelo.HALFSIZE, Gelo.SIZE, Gelo.SIZE);
	}

	public static function create(opts: GeloOptions) {
		final p = new Gelo(opts);

		init(p);

		return p;
	}

	public static function init(p: Gelo) {
		p.spriteVariation = NONE;
		p.updateSubImageCoords();

		p.bounceT = 0;
		p.bounceType = NONE;

		p.popT = 0;
		p.popType = NONE;

		p.isVisible = true;

		p.prevScaleX = 1;
		p.prevScaleY = 1;

		p.scaleX = 1;
		p.scaleY = 1;
		p.willTriggerChain = false;
	}

	@inject final prefsSettings: PrefsSettings;

	@copy var spriteVariation: GeloSpriteVariation;
	@copy var subImageCoords: Point;

	@copy var bounceT: Int;
	@copy var bounceType: GeloBounceType;

	@copy var popT: Int;
	@copy var popType: GeloPopType;

	@copy var isVisible: Bool;

	@copy var prevScaleX: Float;
	@copy var prevScaleY: Float;

	@inject public final color: GeloColor;

	@copy public var scaleX(default, null): Float;
	@copy public var scaleY(default, null): Float;
	@copy public var willTriggerChain: Bool;

	function new(opts: GeloOptions) {
		game.Macros.initFromOpts();
	}

	public function copy(): Dynamic {
		return new Gelo({
			prefsSettings: prefsSettings,
			color: color,
		}).copyFrom(this);
	}

	function updateSubImageCoords() {
		subImageCoords = GELO_SPRITE_COORDINATES[color][spriteVariation];
	}

	function updateTsuBounceType(table: Array<Point>) {
		if (bounceT == table.length) {
			scaleX = 1;
			scaleY = 1;
			stopBouncing();
			return;
		}

		prevScaleX = scaleX;
		prevScaleY = scaleY;

		final current = table[bounceT];

		scaleX = current.x;
		scaleY = current.y;

		bounceT++;
	}

	function updateFeverBounceType() {
		stopBouncing();
	}

	function updateTsuPopType() {
		if (popT == 30) {
			stopPopping();
			return;
		}

		if (popT > 7 && popT % 3 == 0) {
			isVisible = !isVisible;
		}

		popT++;
	}

	function updateFeverPopType() {}

	public function changeSpriteVariation(variation: GeloSpriteVariation) {
		spriteVariation = variation;
		updateSubImageCoords();
	}

	public function startBouncing(type: GeloBounceType) {
		bounceType = type;

		bounceT = 0;
	}

	public function stopBouncing() {
		bounceType = NONE;
	}

	public function startPopping(type: GeloPopType) {
		popType = type;

		scaleX = 1;
		scaleY = 1;

		willTriggerChain = false;
	}

	public function stopPopping() {
		popType = NONE;
	}

	public function update() {
		prevScaleX = scaleX;
		prevScaleY = scaleY;

		switch (bounceType) {
			case TSU_SHORT:
				updateTsuBounceType(GELO_TSU_SHORT_BOUNCE_TABLE);
			case TSU_LONG:
				updateTsuBounceType(GELO_TSU_LONG_BOUNCE_TABLE);
			case FEVER:
				updateFeverBounceType();
			case NONE:
		}

		switch (popType) {
			case TSU:
				updateTsuPopType();
			case FEVER:
				updateFeverPopType();
			case NONE:
		}
	}

	public function render(g: Graphics, g4: Graphics4, x: Float, y: Float, alpha: Float) {
		if (!isVisible)
			return;

		final lerpScaleX = lerp(prevScaleX, scaleX, alpha);
		final lerpScaleY = lerp(prevScaleY, scaleY, alpha);

		final offsetX = x + (1 - lerpScaleX) * Gelo.HALFSIZE;
		final offsetY = y + (1 - lerpScaleY) * Gelo.HALFSIZE;

		if (willTriggerChain) {
			g.pipeline = Pipelines.FADE_TO_WHITE;
			g4.setPipeline(g.pipeline);
		}

		g.color = prefsSettings.colorTints[color];
		g.drawScaledSubImage(Assets.images.pixel, subImageCoords.x, subImageCoords.y, SIZE, SIZE, offsetX - Gelo.HALFSIZE, offsetY - Gelo.HALFSIZE,
			Gelo.SIZE * lerpScaleX, Gelo.SIZE * lerpScaleY);
		g.color = White;

		g.pipeline = null;
	}
}

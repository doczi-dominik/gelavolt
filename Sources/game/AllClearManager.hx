package game;

import game.copying.ICopyFrom;
import game.mediators.BorderColorMediator;
import game.particles.PixelFloatParticle;
import game.particles.SmallStarParticle;
import game.geometries.BoardGeometries;
import game.copying.CopyableRNG;
import game.particles.ParticleManager;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Font;
import utils.Utils;

@:structInit
@:build(game.Macros.buildOptionsClass(AllClearManager))
class AllClearManagerOptions {}

class AllClearManager implements ICopyFrom {
	static final SHORT_STR = "AC!";

	@inject final rng: CopyableRNG;
	@inject final geometries: BoardGeometries;
	@inject final particleManager: ParticleManager;
	@inject final borderColorMediator: BorderColorMediator;

	final font: Font;
	final fontSize: Int;
	final fontHeight: Float;

	@copy var targetY: Float;
	@copy var boardCenterX: Float;

	@copy var line1: String;
	@copy var line2: String;
	@copy var line1HalfWidth: Float;
	@copy var line2HalfWidth: Float;
	@copy var shortStrHalfWidth: Float;

	@copy var t: Int;
	@copy var y: Float;
	@copy var scaleX: Float;
	@copy var showAnimation: Bool;
	@copy var acCounter: Int;

	public var sendAllClearBonus(default, null): Bool;

	public function new(opts: AllClearManagerOptions) {
		game.Macros.initFromOpts();

		targetY = BoardGeometries.HEIGHT / 5;
		boardCenterX = BoardGeometries.CENTER.x;
		font = Assets.fonts.ka1;
		fontSize = 64;
		fontHeight = font.height(fontSize);
		shortStrHalfWidth = font.width(fontSize, SHORT_STR) / 2;

		acCounter = 0;

		sendAllClearBonus = false;
	}

	function setACText(topLine: String, bottomLine: String) {
		line1 = topLine;
		line2 = bottomLine;
		line1HalfWidth = font.width(fontSize, line1) / 2;
		line2HalfWidth = font.width(fontSize, line2) / 2;
	}

	public function startAnimation() {
		t = 0;
		y = BoardGeometries.HEIGHT;
		scaleX = 1;
		showAnimation = true;
		sendAllClearBonus = true;
		borderColorMediator.changeColor(Orange);

		if (rng.data.GetUpTo(Std.int(Math.max(20 / acCounter, 1))) == 1) {
			setACText("RINTO", "MOMENT");
		} else {
			setACText("ALL", "CLEAR");
		}

		acCounter++;
	}

	public function stopAnimation() {
		scaleX = 0;
		showAnimation = false;
		sendAllClearBonus = false;
		borderColorMediator.changeColor(White);
	}

	function updateRisingPhase() {
		final step = t / 45;

		y = Utils.lerp(BoardGeometries.HEIGHT, targetY, Utils.easeOutBack(step));
	}

	function updateTextFlipPhase() {
		scaleX = Utils.lerp(1, -1, (t - 55) / 10);
	}

	function updateSmallStarPhase() {
		final absText = geometries.absolutePosition.add({
			x: BoardGeometries.CENTER.x,
			y: targetY + fontHeight / 2
		});

		final randomX1 = rng.data.GetIn(-192, 192);
		final randomY1 = rng.data.GetIn(-192, 192);
		final randomX2 = rng.data.GetIn(-192, 192);
		final randomY2 = rng.data.GetIn(-192, 192);

		final absPos1 = absText.add({x: randomX1, y: randomY1});
		final absPos2 = absText.add({x: randomX2, y: randomY2});

		particleManager.add(FRONT, SmallStarParticle.create({
			x: absPos1.x,
			y: absPos1.y,
			color: White
		}));

		particleManager.add(FRONT, SmallStarParticle.create({
			x: absPos2.x,
			y: absPos2.y,
			color: Orange
		}));
	}

	function updatePixelFloatPhase() {
		final x = BoardGeometries.WIDTH * rng.data.GetFloatIn(-0.75, 0.75);
		final y = BoardGeometries.HEIGHT * rng.data.GetFloatIn(-0.75, 0.75);

		final absPos = geometries.absolutePosition.add(BoardGeometries.CENTER.add({x: x, y: y}));

		particleManager.add(BACK, PixelFloatParticle.create({
			x: absPos.x,
			y: absPos.y,
			dx: 0,
			dy: rng.data.GetFloatIn(-12, -5),
			maxT: rng.data.GetIn(20, 35),
			color: Orange,
			size: 12
		}));
	}

	public function update() {
		if (!showAnimation)
			return;

		// First phase: Rise text up from the bottom then wait
		// 10 frames
		if (t <= 45) {
			updateRisingPhase();
			// Second phase: Flip the All Clear text either showing the
			// shortened version AC! or nothing.
		} else if (55 < t && t <= 65) {
			updateTextFlipPhase();
		}

		// While waiting in the first phase, add some star particles
		if (t < 55 && t % 3 == 0) {
			updateSmallStarPhase();
		}

		// After the main animation is finished and the shortened AC!
		// text is shown, add pixel floats behind the board
		if (scaleX <= -1) {
			updatePixelFloatPhase();
		}

		t++;
	}

	public function renderBackground(g: Graphics) {
		final scale = -scaleX;

		if (scale <= 0)
			return;

		g.font = font;
		g.fontSize = fontSize;

		final transform = FastMatrix3.translation(boardCenterX, y).multmat(FastMatrix3.scale(scale, 1));

		g.pushTransformation(g.transformation.multmat(transform));
		g.color = Color.fromFloats(0.35, 0.35, 0.35);
		g.drawString(SHORT_STR, -shortStrHalfWidth, 0);
		g.popTransformation();
	}

	public function renderForeground(g: Graphics) {
		if (scaleX <= 0)
			return;

		g.font = font;
		g.fontSize = fontSize;

		final transform = FastMatrix3.translation(boardCenterX, y).multmat(FastMatrix3.scale(scaleX, 1));

		g.pushTransformation(g.transformation.multmat(transform));

		Utils.shadowDrawString(g, 6, Orange, White, line1, -line1HalfWidth, 0);
		Utils.shadowDrawString(g, 6, Orange, White, line2, -line2HalfWidth, fontHeight);

		g.popTransformation();
	}
}

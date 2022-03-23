package game.mediators;

import kha.math.FastMatrix3;
import kha.graphics2.Graphics;

class TransformationMediator {
	public static final PLAY_AREA_DESIGN_WIDTH = 1440;
	public static final PLAY_AREA_DESIGN_HEIGHT = 1080;

	var translationX(default, null): Float;
	var translationY(default, null): Float;

	public function new() {}

	public function onResize() {
		final scr = ScaleManager.screen;

		translationX = (scr.width - PLAY_AREA_DESIGN_WIDTH * scr.smallerScale) / 2;
		translationY = (scr.height - PLAY_AREA_DESIGN_HEIGHT * scr.smallerScale) / 2;
	}

	public function setTransformedScissor(g: Graphics, x: Float, y: Float, w: Float, h: Float) {
		final scale = ScaleManager.screen.smallerScale;

		final tx = Std.int(translationX + x * scale);
		final ty = Std.int(translationY + y * scale);
		final tw = Std.int(w * scale);
		final th = Std.int(h * scale);

		g.scissor(tx, ty, tw, th);
	}

	public function pushTransformation(g: Graphics) {
		final scale = ScaleManager.screen.smallerScale;

		final transform = FastMatrix3.translation(translationX, translationY).multmat(FastMatrix3.scale(scale, scale));
		g.pushTransformation(transform);
	}
}

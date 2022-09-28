package game.boardmanagers;

import main.ScaleManager;
import hxbit.Serializer;
import game.geometries.BoardGeometries;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import game.boards.IBoard;

@:structInit
@:build(game.Macros.buildOptionsClass(SingleBoardManager))
class SingleBoardManagerOptions {}

class SingleBoardManager implements IBoardManager {
	@inject final geometries: BoardGeometries;
	@inject final board: IBoard;

	public function new(opts: SingleBoardManagerOptions) {
		game.Macros.initFromOpts();
	}

	public function addDesyncInfo(ctx: Serializer) {
		board.addDesyncInfo(ctx);
	}

	public function update() {
		board.update();
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		final absPos = geometries.absolutePosition;
		final absX = absPos.x;
		final absY = absPos.y;

		final scale = geometries.scale;

		ScaleManager.transformedScissor(g, absX, absY, BoardGeometries.WIDTH * scale, BoardGeometries.HEIGHT * scale);

		final transform = FastMatrix3.translation(absX, absY).multmat(FastMatrix3.scale(scale, scale));

		g.pushTransformation(g.transformation.multmat(transform));

		board.renderScissored(g, g4, alpha);
		g.disableScissor();

		board.renderFloating(g, g4, alpha);

		g.popTransformation();
	}
}

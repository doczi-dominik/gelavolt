package game.geometries;

import game.boardstates.TrainingInfoBoardState;
import game.gelos.Gelo;
import utils.Point;

@:structInit
class BoardGeometries {
	public static final WIDTH = 384;
	public static final HEIGHT = 768;
	public static final CENTER: Point = {x: WIDTH / 2, y: HEIGHT / 2};

	public static final LEFT: BoardGeometries = {
		absolutePosition: {x: 168, y: 160},
		scale: 1,
		orientation: BoardOrientation.LEFT,
		preview: {x: WIDTH + 48, y: Gelo.HALFSIZE},
		allClearIndicator: {x: CENTER.x, y: HEIGHT / 5},
		scoreDisplayY: HEIGHT + 33,
		garbageTray: {x: 0, y: -Gelo.SIZE - 13},
		editGeloDisplay: {x: WIDTH + 48, y: BoardGeometries.HEIGHT - Gelo.SIZE}
	};

	public static final RIGHT: BoardGeometries = {
		absolutePosition: {x: 888, y: 160},
		scale: 1,
		orientation: BoardOrientation.RIGHT,
		preview: {x: -48, y: Gelo.HALFSIZE},
		allClearIndicator: {x: CENTER.x, y: HEIGHT / 5},
		scoreDisplayY: HEIGHT + 33,
		garbageTray: {x: 0, y: -Gelo.SIZE - 13},
		editGeloDisplay: {x: -48, y: BoardGeometries.HEIGHT - Gelo.SIZE}
	}

	public static final CENTERED: BoardGeometries = {
		absolutePosition: {x: 528, y: 160},
		scale: 1,
		orientation: BoardOrientation.LEFT,
		preview: {x: WIDTH + 48, y: Gelo.HALFSIZE},
		allClearIndicator: {x: CENTER.x, y: HEIGHT / 5},
		scoreDisplayY: HEIGHT + 33,
		garbageTray: {x: 0, y: -Gelo.SIZE - 13},
		editGeloDisplay: {x: WIDTH + 48, y: BoardGeometries.HEIGHT - Gelo.SIZE}
	}

	public static final INFO: BoardGeometries = {
		absolutePosition: {x: 888, y: 160},
		scale: 1,
		orientation: BoardOrientation.RIGHT,
		preview: {x: -48, y: Gelo.HALFSIZE},
		allClearIndicator: {x: CENTER.x, y: HEIGHT / 5},
		scoreDisplayY: HEIGHT + 33,
		garbageTray: {x: TrainingInfoBoardState.GAME_INFO_X, y: -Gelo.SIZE - 13},
		editGeloDisplay: {x: -48, y: BoardGeometries.HEIGHT - Gelo.SIZE}
	}

	public final absolutePosition: Point;
	public final scale: Float;

	public final orientation: BoardOrientation;

	public final preview: Point;
	public final allClearIndicator: Point;
	public final scoreDisplayY: Float;
	public final garbageTray: Point;
	public final editGeloDisplay: Point;
}

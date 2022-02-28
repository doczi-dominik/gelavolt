package game.boardmanagers;

import game.mediators.TransformationMediator;
import game.boards.IBoard;
import game.geometries.BoardGeometries;

@:structInit
class SingleBoardManagerOptions {
	public final transformMediator: TransformationMediator;
	public final geometries: BoardGeometries;
	public final board: IBoard;
}

package game.boardmanagers;

import game.boards.IBoard;
import game.screens.GameScreen;
import game.geometries.BoardGeometries;

@:structInit
class SingleBoardManagerOptions {
	public final gameScreen: GameScreen;
	public final geometries: BoardGeometries;
	public final board: IBoard;
}

package game.mediators;

import kha.Color;
import game.boardstates.StandardBoardState;

class BorderColorMediator {
	public var boardState(null, default): StandardBoardState;

	public function new() {}

	public inline function changeColor(target: Color) {
		boardState.changeBorderColor(target);
	}
}

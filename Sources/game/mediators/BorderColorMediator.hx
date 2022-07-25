package game.mediators;

import kha.Color;
import game.boardstates.StandardBoardState;

/**
 * `BorderColorMediator` provides access to a StandardBoardState's border
 * color changing ability. Notably, it's used in `AllClearManager` to change
 * the border color to golden whenever an All Clear is triggered.
 * 
 * While a `StandardBoardState` could change its border color when triggering
 * an All Clear, using the `BorderColorMediator` allows easy changing from e.g.
 * the pause menu.
 */
class BorderColorMediator {
	public var changeColor: Color->Void;

	public function new() {}
}

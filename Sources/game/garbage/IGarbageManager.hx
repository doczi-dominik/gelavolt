package game.garbage;

import game.copying.ICopyFrom;
import game.gelos.ScreenGeloPoint;
import kha.graphics2.Graphics;

interface IGarbageManager extends ICopyFrom {
	public var canReceiveGarbage: Bool;
	public var droppableGarbage(get, never): Int;

	public function sendGarbage(amount: Int, beginners: Array<ScreenGeloPoint>): Void;
	public function dropGarbage(amount: Int): Void;
	public function confirmGarbage(amount: Int): Void;
	public function clear(): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float, alpha: Float): Void;
}

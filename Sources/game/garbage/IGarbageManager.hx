package game.garbage;

import hxbit.Serializer;
import game.copying.ICopyFrom;
import game.gelos.ScreenGeloPoint;
import kha.graphics2.Graphics;

interface IGarbageManager extends ICopyFrom extends hxbit.Serializable {
	public var canReceiveGarbage: Bool;
	public var droppableGarbage(get, never): Int;

	public function sendGarbage(amount: Int, beginners: Array<ScreenGeloPoint>, sendsAllClearBonus: Bool): Void;
	public function dropGarbage(amount: Int): Void;
	public function confirmGarbage(amount: Int): Void;
	public function clear(): Void;

	public function addDesyncInfo(ctx: Serializer): Void;
	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float, alpha: Float): Void;
}

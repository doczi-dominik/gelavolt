package game.boards;

import hxbit.Serializer;
import game.copying.ICopyFrom;
import input.IInputDevice;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IBoard extends ICopyFrom {
	private final inputDevice: IInputDevice;

	public function addDesyncInfo(ctx: Serializer): Void;
	public function update(): Void;
	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float): Void;
	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float): Void;
}

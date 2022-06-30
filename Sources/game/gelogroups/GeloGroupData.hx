package game.gelogroups;

import haxe.ds.Vector;
import game.gelos.OtherGeloPositions.OTHERGELO_POSITIONS;
import game.gelos.Gelo;
import kha.graphics2.Graphics;
import game.gelos.GeloColor;
import game.gelos.OtherGelo.OtherGeloOptions;

@:structInit
class GeloGroupData {
	public var mainColor: GeloColor;
	public final others: Vector<OtherGeloOptions>;

	public function render(g: Graphics, x: Float, y: Float) {
		for (o in others) {
			final relativePos = OTHERGELO_POSITIONS[o.positionID][0];

			Gelo.renderStatic(g, x + relativePos.x * Gelo.SIZE, y + relativePos.y * Gelo.SIZE, o.color, NONE);
		}

		Gelo.renderStatic(g, x, y, mainColor, NONE);
	}
}

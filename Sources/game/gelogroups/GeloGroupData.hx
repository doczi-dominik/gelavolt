package game.gelogroups;

import game.copying.ICopy;
import game.copying.CopyableArray;
import game.gelos.OtherGeloPositions.OTHERGELO_POSITIONS;
import game.gelos.Gelo;
import kha.graphics2.Graphics;
import game.gelos.GeloColor;
import game.gelos.OtherGelo.OtherGeloOptions;

class GeloGroupData implements ICopy {
	public var mainColor: GeloColor;
	public final others: CopyableArray<OtherGeloOptions>;

	public function new(mainColor: GeloColor, others: Array<OtherGeloOptions>) {
		this.mainColor = mainColor;
		this.others = new CopyableArray(others);
	}

	public function copy(): Dynamic {
		return new GeloGroupData(mainColor, others.data);
	}

	public function render(g: Graphics, x: Float, y: Float) {
		for (o in others.data) {
			final relativePos = OTHERGELO_POSITIONS[o.positionID][0];

			Gelo.renderStatic(g, x + relativePos.x * Gelo.SIZE, y + relativePos.y * Gelo.SIZE, o.color, NONE);
		}

		Gelo.renderStatic(g, x, y, mainColor, NONE);
	}
}

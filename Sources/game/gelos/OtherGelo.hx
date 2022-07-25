package game.gelos;

import game.copying.ICopy;
import game.gelos.Gelo.GeloOptions;
import game.gelos.OtherGeloPositions.OTHERGELO_POSITIONS;

@:structInit
@:build(game.Macros.buildOptionsClass(OtherGelo))
class OtherGeloOptions extends GeloOptions implements ICopy {
	public function copy() {
		return this;
	}
}

class OtherGelo extends Gelo {
	public static function create(opts: OtherGeloOptions) {
		final p = new OtherGelo(opts);

		init(p);

		return p;
	}

	public static function init(p: OtherGelo) {
		Gelo.init(p);

		p.changeRotation(0);
	}

	@inject final positionID: Int;

	@copy public var relX: Int;
	@copy public var relY: Int;

	override function copy() {
		return new OtherGelo({
			prefsSettings: prefsSettings,
			color: color,
			positionID: positionID
		}).copyFrom(this);
	}

	function new(opts: OtherGeloOptions) {
		super(opts);

		game.Macros.initFromOpts();
	}

	public function changeRotation(rotationID: Int) {
		final rot = getRotation(rotationID);

		relX = rot.x;
		relY = rot.y;
	}

	public function getRotation(rotationID: Int) {
		return OTHERGELO_POSITIONS[positionID][rotationID];
	}
}

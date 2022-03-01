package game.gelos;

import game.gelos.OtherGeloPositions.OTHERGELO_POSITIONS;
import utils.IntPoint;

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

	public static function copyTo(src: OtherGelo, dest: OtherGelo) {
		Gelo.copyTo(src, dest);

		dest.relX = src.relX;
		dest.relY = src.relY;
	}

	final positionID: Int;

	public var relX: Int;
	public var relY: Int;

	override function copyFrom(src: Gelo) {
		copyTo(cast(src, OtherGelo), this);
	}

	override function copy(): Gelo {
		final p = new OtherGelo({
			prefsSettings: prefsSettings,
			color: color,
			positionID: positionID
		});

		p.copyFrom(this);

		return p;
	}

	function new(opts: OtherGeloOptions) {
		super(opts);

		positionID = opts.positionID;
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

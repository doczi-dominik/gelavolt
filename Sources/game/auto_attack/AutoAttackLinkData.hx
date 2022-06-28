package game.auto_attack;

import game.gelos.GeloColor;

class AutoAttackLinkData {
	public final clearsByColor: Map<GeloColor, Int>;

	public var sendsAllClearBonus: Bool;

	public function new() {
		clearsByColor = [COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0];

		sendsAllClearBonus = false;
	}
}

package game.mediators;

import game.garbage.GarbageManager;
import game.geometries.BoardGeometries;

@:structInit
@:access(game.garbage.GarbageManager)
class GarbageTargetMediator {
	public final geometries: BoardGeometries;
	@:optional public var garbageManager(null, default): GarbageManager;

	public function startAnimation() {
		garbageManager.startAnimation();
	}

	public function receiveGarbage(amount: Int) {
		garbageManager.receiveGarbage(amount);
	}

	public function setConfirmedGarbage(amount: Int) {
		garbageManager.setConfirmedGarbage(amount);
	}
}

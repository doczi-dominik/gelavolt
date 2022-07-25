package game.mediators;

import game.copying.ICopyFrom;
import game.copying.ConstantCopyableArray;
import ui.ControlHint;

class ControlHintContainer implements ICopyFrom {
	@copy public final value: ConstantCopyableArray<ControlHint>;

	@copy public var isVisible: Bool;

	public function new() {
		isVisible = false;
		value = new ConstantCopyableArray([]);
	}
}

package versus_setup;

import kha.graphics2.Graphics;

class InputSlot {
	final capacity: Int;
	final data: Array<InputManagerIcon>;

	public function new(capacity: Int) {
		this.capacity = capacity;
		data = [];
	}

	function unassign(icon: InputManagerIcon) {
		data.remove(icon);
	}

	public inline function canAssign() {
		return data.length < capacity;
	}

	public function assign(icon: InputManagerIcon) {
		icon.slot.unassign(icon);

		data.push(icon);
		icon.slot = this;
	}

	public function render(g: Graphics, x: Float) {
		for (i in 0...data.length) {
			final icon = data[i];

			g.drawString(icon.name, x, ScaleManager.height / 2 + i * 32);
		}
	}
}

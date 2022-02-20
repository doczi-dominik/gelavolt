package game.actionbuffers;

class ActionSnapshot {
	public var frame: Int;

	public var shiftLeft(default, null): Bool;
	public var shiftRight(default, null): Bool;
	public var rotateLeft(default, null): Bool;
	public var rotateRight(default, null): Bool;
	public var softDrop(default, null): Bool;
	public var hardDrop(default, null): Bool;

	public function new() {}

	public function setFrame(value: Int) {
		frame = value;

		return this;
	}

	public function setShiftLeft(value: Bool) {
		shiftLeft = value;

		return this;
	}

	public function setShiftRight(value: Bool) {
		shiftRight = value;

		return this;
	}

	public function setRotateLeft(value: Bool) {
		rotateLeft = value;

		return this;
	}

	public function setRotateRight(value: Bool) {
		rotateRight = value;

		return this;
	}

	public function setSoftDrop(value: Bool) {
		softDrop = value;

		return this;
	}

	public function setHardDrop(value: Bool) {
		hardDrop = value;

		return this;
	}

	public function isNotEqual(other: ActionSnapshot) {
		return softDrop != other.softDrop || shiftLeft != other.shiftLeft || shiftRight != other.shiftRight || rotateLeft != other.rotateLeft
			|| rotateRight != other.rotateRight || hardDrop != other.hardDrop;
	}
}

package game.actionbuffers;

@:structInit
class ActionSnapshot {
	public static function fromBitField(bitField: Int) {
		final s: ActionSnapshot = {
			shiftLeft: bitField & 32 == 32,
			shiftRight: bitField & 16 == 16,
			rotateLeft: bitField & 8 == 8,
			rotateRight: bitField & 4 == 4,
			softDrop: bitField & 2 == 2,
			hardDrop: bitField & 1 == 1
		};

		return s;
	}

	public final shiftLeft: Bool;
	public final shiftRight: Bool;
	public final rotateLeft: Bool;
	public final rotateRight: Bool;
	public final softDrop: Bool;
	public final hardDrop: Bool;

	public function toBitField() {
		return (shiftLeft ? 1 << 5 : 0) + (shiftRight ? 1 << 4 : 0) + (rotateLeft ? 1 << 3 : 0) + (rotateRight ? 1 << 2 : 0) + (softDrop ? 1 << 1 : 0)
			+ (hardDrop ? 1 : 0);
	}

	public function isNotEqual(other: ActionSnapshot) {
		return softDrop != other.softDrop || shiftLeft != other.shiftLeft || shiftRight != other.shiftRight || rotateLeft != other.rotateLeft
			|| rotateRight != other.rotateRight || hardDrop != other.hardDrop;
	}
}

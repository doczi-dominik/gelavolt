package game.gelos;

enum abstract GeloColor(Int) from Int to Int {
	final COLOR1 = 0;
	final COLOR2 = 1;
	final COLOR3 = 2;
	final COLOR4 = 3;
	final COLOR5 = 4;
	final EMPTY = 5;
	final GARBAGE = 6;

	public function isColored() {
		return 0 <= this && this <= 4;
	}

	public function isEmpty() {
		return this == 99;
	}

	public function isGarbage() {
		return 5 <= this;
	}
}

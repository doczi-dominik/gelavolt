package input;

// Modelled after a DS4 to avoid ambiguity between Xbox and Switch ABXY
enum abstract GamepadButton(Int) from Int to Int {
	final CROSS = 0;
	final CIRCLE;
	final SQUARE;
	final TRIANGLE;
	final L1;
	final R1;
	final L2;
	final R2;
	final SHARE;
	final OPTIONS;
	final L3;
	final R3;
	final DPAD_UP;
	final DPAD_DOWN;
	final DPAD_LEFT;
	final DPAD_RIGHT;
}

package game.gelos;

enum abstract GeloSpriteVariation(Int) from Int to Int {
	final NONE = 0;
	final CON_DOWN = 4;
	final CON_UP = 8;
	final CON_UP_DOWN = 12;
	final CON_RIGHT = 1;
	final CON_DOWN_RIGHT = 5;
	final CON_UP_RIGHT = 9;
	final CON_UP_DOWN_RIGHT = 13;
	final CON_LEFT = 2;
	final CON_DOWN_LEFT = 6;
	final CON_UP_LEFT = 10;
	final CON_UP_DOWN_LEFT = 14;
	final CON_LEFT_RIGHT = 3;
	final CON_DOWN_LEFT_RIGHT = 7;
	final CON_UP_LEFT_RIGHT = 11;
	final CON_UP_DOWN_LEFT_RIGHT = 15;
}

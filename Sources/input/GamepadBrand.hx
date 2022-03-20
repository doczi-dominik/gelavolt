package input;

enum abstract GamepadBrand(String) from String to String {
	final DS4;
	final SW_PRO = "SW Pro Controller";
	final JOYCON;
	final XBONE;
	final XB360;
}

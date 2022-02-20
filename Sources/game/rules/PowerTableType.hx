package game.rules;

enum abstract PowerTableType(String) from String to String {
	final OPP;
	final TSU;
	final TSU_SINGLEPLAYER = "TSU (Singleplayer)";
}

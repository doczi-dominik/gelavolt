package game.net;

enum abstract SessionState(Int) {
	final CONNECTING;
	final SYNCING;
	final READY;
}

package game.net;

enum abstract SessionState(Int) {
	final CONNECTING;
	final SYNCING;
	final BEGINNING;
	final RUNNING;
}

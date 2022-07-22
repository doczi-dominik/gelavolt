package game.net;

enum abstract SessionState(Int) to Int {
	final CONNECTING;
	final WAITING;
	final SYNCING;
	final BEGINNING;
	final RUNNING;
}

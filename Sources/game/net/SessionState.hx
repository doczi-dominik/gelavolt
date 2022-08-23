package game.net;

enum abstract SessionState(Int) to Int {
	final WAITING;
	final SYNCING;
	final BEGINNING;
	final RUNNING;
}

package game.net.packets;

enum abstract PacketType(Int) {
	final SYNC_REQ;
	final SYNC_RESP;
	final INPUT;
	final BEGIN_REQ;
	final BEGIN_RESP;
}

package game.net;

enum abstract PacketType(Int) from Int {
	final INPUT;
	final SYNC_REQ;
	final SYNC_RESP;
	final INPUT_ACK;
	final BEGIN_REQ;
	final BEGIN_RESP;
	final CHECKSUM_FRAME_REQ;
	final CHECKSUM_FRAME_RESP;
	final CHECKSUM_UPDATE;
}

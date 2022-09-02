package game.net;

enum abstract PacketType(String) from String {
	final INPUT = "0";
	final SYNC_REQ = "1";
	final SYNC_RESP = "2";
	final INPUT_ACK = "3";
	final BEGIN_REQ = "4";
	final BEGIN_RESP = "5";
	final CHECKSUM_REQ = "6";
	final CHECKSUM_RESP = "7";
	final CHECKSUM_UPDATE = "8";
}

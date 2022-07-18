package game.net.packets;

class PacketBase implements hxbit.Serializable {
	@:s public var type: PacketType;
	@:s public var magic: String;

	function new(type: PacketType, magic: String) {
		this.type = type;
		this.magic = magic;
	}
}

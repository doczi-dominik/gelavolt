package game.net.packets;

class PacketBase implements hxbit.Serializable {
	@:s public var type: PacketType;

	function new(type: PacketType) {
		this.type = type;
	}
}

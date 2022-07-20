package game.net.packets;

class BeginRequestPacket extends PacketBase {
	@:s public var options: NetplayOptions;

	public function new(magic: String, options: NetplayOptions) {
		super(BEGIN_REQ, magic);

		this.options = options;
	}
}

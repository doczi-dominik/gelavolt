package game.net.packets;

class BeginRequestPacket extends PacketBase {
	@:s public var options: NetplayOptions;

	public function new(options: NetplayOptions) {
		super(BEGIN_REQ);

		this.options = options;
	}
}

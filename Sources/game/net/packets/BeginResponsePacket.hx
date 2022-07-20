package game.net.packets;

class BeginResponsePacket extends PacketBase {
	@:s public var beginFrame(default, null): Int;

	public function new(magic: String, beginFrame: Int) {
		super(BEGIN_RESP, magic);

		this.beginFrame = beginFrame;
	}
}

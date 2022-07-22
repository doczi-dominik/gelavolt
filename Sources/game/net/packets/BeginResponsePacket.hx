package game.net.packets;

class BeginResponsePacket extends PacketBase {
	@:s public var beginFrame(default, null): Int;

	public function new(beginFrame: Int) {
		super(BEGIN_RESP);

		this.beginFrame = beginFrame;
	}
}

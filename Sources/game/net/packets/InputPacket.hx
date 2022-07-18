package game.net.packets;

class InputPacket extends PacketBase {
	@:s public var frame: Int;
	@:s public var actions: Int;

	public function new(magic: String, frame: Int, actions: Int) {
		super(INPUT, magic);

		this.frame = frame;
		this.actions = actions;
	}
}

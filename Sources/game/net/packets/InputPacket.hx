package game.net.packets;

class InputPacket extends PacketBase {
	@:s public var frame: Int;
	@:s public var actions: Int;

	public function new(frame: Int, actions: Int) {
		super(INPUT);

		this.frame = frame;
		this.actions = actions;
	}
}

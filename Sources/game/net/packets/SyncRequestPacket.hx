package game.net.packets;

class SyncRequestPacket extends PacketBase {
	@:s public var framePrediction: Null<Int>;

	public function new(magic: String, framePrediction: Null<Int>) {
		super(SYNC_REQ, magic);

		this.framePrediction = framePrediction;
	}
}

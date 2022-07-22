package game.net.packets;

class SyncRequestPacket extends PacketBase {
	@:s public var framePrediction: Null<Int>;

	public function new(framePrediction: Null<Int>) {
		super(SYNC_REQ);

		this.framePrediction = framePrediction;
	}
}

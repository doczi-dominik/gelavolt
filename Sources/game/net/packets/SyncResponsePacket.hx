package game.net.packets;

class SyncResponsePacket extends PacketBase {
	@:s public var frameAdvantage: Null<Int>;

	public function new(magic: String, frameAdvantage: Null<Int>) {
		super(SYNC_RESP, magic);

		this.frameAdvantage = frameAdvantage;
	}
}

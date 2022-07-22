package game.net.packets;

class SyncResponsePacket extends PacketBase {
	@:s public var frameAdvantage: Null<Int>;

	public function new(frameAdvantage: Null<Int>) {
		super(SYNC_RESP);

		this.frameAdvantage = frameAdvantage;
	}
}

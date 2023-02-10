package game.net.logger;

interface ISessionLogger {
	public function enableRingBuffer(): Void;
	public function disableRingBuffer(): Void;
	public function push(message: String): Void;
	public function download(): Void;
}

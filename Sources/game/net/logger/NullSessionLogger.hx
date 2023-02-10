package game.net.logger;

class NullSessionLogger implements ISessionLogger {
	public static final instance = new NullSessionLogger();

	function new() {}

	public function enableRingBuffer() {}

	public function disableRingBuffer() {}

	public function push(message: String) {}

	public function download() {}
}

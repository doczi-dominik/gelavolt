package game.net.logger;

class NullSessionLogger implements ISessionLogger {
	public static final instance = new NullSessionLogger();

	public var useGameLog = false;

	function new() {}

	public function push(message: String) {}

	public function download() {}
}

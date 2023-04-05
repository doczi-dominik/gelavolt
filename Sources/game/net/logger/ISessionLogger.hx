package game.net.logger;

interface ISessionLogger {
	public var useGameLog: Bool;

	public function push(message: String): Void;
	public function download(): Void;
}

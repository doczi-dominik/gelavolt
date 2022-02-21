package game.simulation;

@:structInit
class EndSimStepOptions extends SimulationStepOptions {
	public final links: Array<LinkInfo>;
	public final endsInAllClear: Bool;
}

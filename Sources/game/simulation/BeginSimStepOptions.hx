package game.simulation;

@:structInit
class BeginSimStepOptions extends SimulationStepOptions {
	public final sendsAllClearBonus: Bool;
	public final dropBonus: Float;
	public final groupIndex: Int;
}

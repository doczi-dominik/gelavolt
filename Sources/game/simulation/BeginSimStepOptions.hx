package game.simulation;

import game.gelogroups.GeloGroupData;

@:structInit
class BeginSimStepOptions extends SimulationStepOptions {
	@:optional public final groupData: Null<GeloGroupData> = null;

	public final sendsAllClearBonus: Bool;
	public final dropBonus: Float;
	public final groupIndex: Int;
}

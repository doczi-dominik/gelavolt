package game.simulation;

import game.rules.Rule;
import game.garbage.trays.GarbageTray;

@:structInit
class ChainSimulatorOptions {
	public final rule: Rule;
	public final linkBuilder: ILinkInfoBuilder;
	public final garbageDisplay: GarbageTray;
	public final accumulatedDisplay: GarbageTray;
}

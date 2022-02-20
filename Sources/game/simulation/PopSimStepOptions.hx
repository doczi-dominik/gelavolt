package game.simulation;

import game.garbage.trays.GarbageTray;
import game.fields.FieldPopInfo;

@:structInit
class PopSimStepOptions extends SimulationStepOptions {
	public final garbageDisplay: GarbageTray;
	public final accumulatedDisplay: GarbageTray;

	public final popInfo: FieldPopInfo;
	public final linkInfo: LinkInfo;
}

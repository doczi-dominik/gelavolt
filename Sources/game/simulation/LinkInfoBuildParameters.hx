package game.simulation;

import game.gelos.GeloColor;

@:structInit
class LinkInfoBuildParameters {
	public final clearsByColor: Map<GeloColor, Int>;
	public final chain: Int;
	public final dropBonus: Float;
	public final garbageRemainder: Float;
	public final sendsAllClearBonus: Bool;
	public final totalGarbage: Int;
}

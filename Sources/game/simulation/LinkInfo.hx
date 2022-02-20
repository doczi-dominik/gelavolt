package game.simulation;

@:structInit
class LinkInfo {
	public final chain: Int;
	public final score: Int;
	public final clearCount: Int;
	public final chainPower: Int;
	public final groupBonus: Int;
	public final colorBonus: Int;

	public final garbage: Int;
	public final accumulatedGarbage: Int;
	public final garbageRemainder: Float;
	public final sendsAllClearBonus: Bool;

	public final isPowerful: Bool;
}

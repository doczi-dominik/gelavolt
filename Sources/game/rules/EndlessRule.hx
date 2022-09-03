package game.rules;

@:structInit
class EndlessRule implements IRule {
	public final rngSeed: Int;
	public final marginTime: Int;
	public final targetPoints: Int;
	public final softDropBonus: Float;
	public final popCount: Int;
	public final vanishHiddenRows: Bool;
	public final groupBonusTableType: GroupBonusTableType;
	public final colorBonusTableType: ColorBonusTableType;
	public final powerTableType: PowerTableType;
	public final dropBonusGarbage: Bool;
	public final allClearReward: Int;
	public final physics: PhysicsType;
	public final animations: AnimationsType;
	public final dropSpeed: Float;
	public final randomizeGarbage: Bool;
}

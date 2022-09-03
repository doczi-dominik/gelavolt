package game.rules;

@:structInit
class EndlessRule implements IRule {
	@:s public var rngSeed(default, null): Int;
	@:s public var marginTime(default, null): Int;
	@:s public var targetPoints(default, null): Int;
	@:s public var softDropBonus(default, null): Float;
	@:s public var popCount(default, null): Int;
	@:s public var vanishHiddenRows(default, null): Bool;
	@:s public var groupBonusTableType(default, null): GroupBonusTableType;
	@:s public var colorBonusTableType(default, null): ColorBonusTableType;
	@:s public var powerTableType(default, null): PowerTableType;
	@:s public var dropBonusGarbage(default, null): Bool;
	@:s public var allClearReward(default, null): Int;
	@:s public var physics(default, null): PhysicsType;
	@:s public var animations(default, null): AnimationsType;
	@:s public var dropSpeed(default, null): Float;
	@:s public var randomizeGarbage(default, null): Bool;
}

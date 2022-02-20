package game.rules;

import game.gelos.GeloColor;
import game.randomizers.RandomizerType;
import game.rules.GroupBonusTableType;
import game.rules.AnimationsType;
import game.rules.PhysicsType;

@:structInit
class Rule {
	public var animations = AnimationsType.TSU;
	public var physics = PhysicsType.TSU;

	// Misc.
	public var randomizerType = RandomizerType.TSU;
	public var popCount = 4;
	public var minimumChain = 1;
	public var softDropBonus = 0.5;
	public var dropSpeed = 2.6;
	public var vanishHiddenRows = false;
	public var randomizeGarbage = true;

	// Scoring
	public var powerTableType = PowerTableType.TSU;
	public var colorBonusTableType = ColorBonusTableType.TSU;
	public var groupBonusTableType = GroupBonusTableType.TSU;

	// Garbage
	public var marginTime = 96;
	public var startTargetPoints = 70;
	public var garbageColor = GeloColor.GARBAGE;
	public var offsetMode = OffsetMode.TSU;
	public var countering = true;
	public var dropBonusGarbage = true;
	public var allClearReward = 30;
	public var baseChainOnAllClear = false;
	public var garbageDropLimit = 30;
	public var garbageConfirmGracePeriod = 30;
}

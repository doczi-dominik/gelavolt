package game.rules;

import game.gelos.GeloColor;
import game.randomizers.RandomizerType;
import game.rules.GroupBonusTableType;
import game.rules.AnimationsType;
import game.rules.PhysicsType;

@:structInit
class Rule implements hxbit.Serializable {
	@:s public var animations = AnimationsType.TSU;
	@:s public var physics = PhysicsType.TSU;

	// Misc.
	@:s public var randomizerType = RandomizerType.TSU;
	@:s public var popCount = 4;
	@:s public var minimumChain = 1;
	@:s public var softDropBonus = 0.5;
	@:s public var dropSpeed = 2.6;
	@:s public var vanishHiddenRows = false;
	@:s public var randomizeGarbage = true;

	// Scoring
	@:s public var powerTableType = PowerTableType.TSU;
	@:s public var colorBonusTableType = ColorBonusTableType.TSU;
	@:s public var groupBonusTableType = GroupBonusTableType.TSU;

	// Garbage
	@:s public var marginTime = 96;
	@:s public var startTargetPoints = 70;
	@:s public var garbageColor = GeloColor.GARBAGE;
	@:s public var offsetMode = OffsetMode.TSU;
	@:s public var countering = true;
	@:s public var dropBonusGarbage = true;
	@:s public var allClearReward = 30;
	@:s public var baseChainOnAllClear = false;
	@:s public var garbageDropLimit = 30;
	@:s public var garbageConfirmGracePeriod = 30;
}

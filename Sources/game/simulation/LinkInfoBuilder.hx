package game.simulation;

import game.rules.PowerTableType;
import game.rules.ColorBonusTableType;
import game.rules.GroupBonusTableType;
import utils.ValueBox;
import game.rules.PowerTables.POWER_TABLES;
import game.rules.ColorBonusTables.COLOR_BONUS_TABLES;
import game.rules.GroupBonusTables.GROUP_BONUS_TABLES;
import utils.Utils;
import game.rules.MarginTimeManager;

@:structInit
@:build(game.Macros.buildOptionsClass(LinkInfoBuilder))
class LinkInfoBuilderOptions {}

class LinkInfoBuilder implements ILinkInfoBuilder {
	@inject final groupBonusTableType: ValueBox<GroupBonusTableType>;
	@inject final colorBonusTableType: ValueBox<ColorBonusTableType>;
	@inject final powerTableType: ValueBox<PowerTableType>;
	@inject final dropBonusGarbage: ValueBox<Bool>;
	@inject final allClearReward: ValueBox<Int>;
	@inject final marginManager: MarginTimeManager;

	public function new(opts: LinkInfoBuilderOptions) {
		game.Macros.initFromOpts();
	}

	public function build(params: LinkInfoBuildParameters): LinkInfo {
		final chain = params.chain;

		var colorCount = 0;
		var clearCount = 0;
		var groupBonus = 0;

		final groupBonusTable = GROUP_BONUS_TABLES[groupBonusTableType];
		final colorBonusTable = COLOR_BONUS_TABLES[colorBonusTableType];
		final powerTable = POWER_TABLES[powerTableType];

		for (c in params.clearsByColor) {
			if (c <= 0)
				continue;

			groupBonus += groupBonusTable.get(c);
			clearCount += c;
			colorCount++;
		}

		final colorBonus = colorBonusTable[colorCount - 1];
		final chainPower = powerTable.get(chain);

		final bonuses = groupBonus + colorBonus;
		final score = 10 * clearCount * Utils.intClamp(1, chainPower + bonuses, 999);

		final garbageScore = (dropBonusGarbage) ? score + params.dropBonus : score;

		var garbageFloat = garbageScore / marginManager.targetPoints + params.garbageRemainder;
		if (params.sendsAllClearBonus)
			garbageFloat += (allClearReward : Int);

		final garbage = Std.int(garbageFloat);
		final garbageRemainder = garbageFloat - garbage;

		return {
			chain: chain,
			score: score,
			clearCount: clearCount,
			chainPower: chainPower,
			groupBonus: groupBonus,
			colorBonus: colorBonus,

			garbage: garbage,
			accumulatedGarbage: params.totalGarbage + garbage,
			garbageRemainder: garbageRemainder,
			sendsAllClearBonus: params.sendsAllClearBonus,

			isPowerful: bonuses > 0,
		};
	}
}

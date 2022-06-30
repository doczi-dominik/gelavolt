package game.simulation;

import game.rules.PowerTables.POWER_TABLES;
import game.rules.ColorBonusTables.COLOR_BONUS_TABLES;
import game.rules.GroupBonusTables.GROUP_BONUS_TABLES;
import utils.Utils;
import game.rules.MarginTimeManager;
import game.rules.Rule;

@:structInit
@:build(game.Macros.buildOptionsClass(LinkInfoBuilder))
class LinkInfoBuilderOptions {}

class LinkInfoBuilder implements ILinkInfoBuilder {
	@inject final rule: Rule;
	@inject final marginManager: MarginTimeManager;

	public function new(opts: LinkInfoBuilderOptions) {
		game.Macros.initFromOpts();
	}

	public function build(params: LinkInfoBuildParameters): LinkInfo {
		final chain = params.chain;

		var colorCount = 0;
		var clearCount = 0;
		var groupBonus = 0;

		final groupBonusTable = GROUP_BONUS_TABLES[rule.groupBonusTableType];
		final colorBonusTable = COLOR_BONUS_TABLES[rule.colorBonusTableType];
		final powerTable = POWER_TABLES[rule.powerTableType];

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

		final garbageScore = (rule.dropBonusGarbage) ? score + params.dropBonus : score;

		var garbageFloat = garbageScore / marginManager.targetPoints + params.garbageRemainder;
		if (params.sendsAllClearBonus)
			garbageFloat += rule.allClearReward;

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

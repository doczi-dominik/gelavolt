package game.randomizers;

import game.copying.ICopyFrom;
import game.copying.CopyableRNG;
import save_data.PrefsSettings;
import game.gelos.OtherGelo.OtherGeloOptions;
import game.gelogroups.GeloGroupData;
import game.gelogroups.GeloGroupType;
import game.gelos.GeloColor;
import haxe.ds.Vector;
import game.randomizers.RandomizerPool;

@:structInit
@:build(game.Macros.buildOptionsClass(Randomizer))
class RandomizerOptions {}

class Randomizer implements ICopyFrom {
	@inject final rng: CopyableRNG;
	@inject final prefsSettings: PrefsSettings;

	var pools: Map<RandomizerPool, Vector<GeloColor>>;

	@copy public var currentPool: RandomizerPool;

	public function new(opts: RandomizerOptions) {
		game.Macros.initFromOpts();
	}

	function tsu() {
		final colorSet = [COLOR1, COLOR2, COLOR3, COLOR4, COLOR5];

		var swapWith: Int;
		var temp: GeloColor;
		var index = 5;

		// Shuffle color set
		for (_ in 0...5) {
			while (--index >= 0) {
				swapWith = rng.data.GetUpTo(index);

				temp = colorSet[index];
				colorSet[index] = colorSet[swapWith];
				colorSet[swapWith] = temp;
			}
		}

		// Generate 3 pools and swap colors around
		for (p in THREE_COLOR...FIVE_COLOR + 1) {
			pools[p] = new Vector(256);

			final pool = pools[p];

			for (i in 0...256) {
				pool[i] = colorSet[i % p];
			}

			index = 256;

			while (--index >= 0) {
				swapWith = rng.data.GetUpTo(255);

				temp = pool[index];
				pool[index] = pool[swapWith];
				pool[swapWith] = temp;
			}
		}

		// Ensure 3-color start
		for (i in 0...4) {
			pools[FOUR_COLOR][i] = pools[THREE_COLOR][3 - i];
		}

		// Ensure 4-color start
		for (i in 0...4) {
			pools[FIVE_COLOR][3 + i] = pools[FOUR_COLOR][6 - i];
		}
	}

	public function generatePools(type: RandomizerType) {
		pools = [];

		switch (type) {
			case TSU:
				tsu();
		}
	}

	public function createQueueData(dropset: Array<GeloGroupType>) {
		final p = pools[currentPool];
		final groups: Array<GeloGroupData> = [];

		var index = 0;
		var mainColor: Null<GeloColor>;
		var otherOptions: Array<OtherGeloOptions>;

		while (index < 256) {
			for (type in dropset) {
				otherOptions = [];

				for (i in 0...8) {
					otherOptions[i] = {
						prefsSettings: prefsSettings,
						color: EMPTY,
						positionID: i
					}
				}

				switch (type) {
					case PAIR:
						mainColor = p[index++];
						final otherColor: Null<GeloColor> = p[index++];

						if (mainColor == null || otherColor == null) {
							return groups;
						}

						otherOptions[1].color = otherColor;
				}

				groups.push(new GeloGroupData(mainColor, otherOptions));
			}
		}

		return groups;
	}
}

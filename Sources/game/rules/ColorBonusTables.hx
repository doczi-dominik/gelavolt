package game.rules;

import haxe.ds.ReadOnlyArray;

final COLOR_BONUS_TABLES: Map<ColorBonusTableType, ReadOnlyArray<Int>> = [TSU => [0, 3, 6, 12, 24], FEVER => [0, 2, 4, 8, 16]];

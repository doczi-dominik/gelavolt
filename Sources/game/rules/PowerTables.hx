package game.rules;

import game.rules.QueryablePowerTable;

final POWER_TABLES: Map<PowerTableType, QueryablePowerTable> = [
	OPP => {values: [0, 8, 16, 32, 64, 128, 256, 512, 999], increment: 0},
	TSU => {values: [0, 8, 16, 32], increment: 32},
	TSU_SINGLEPLAYER => {values: [4, 20, 24, 32, 48, 96, 160, 240, 320, 480, 600, 700, 800, 900, 999], increment: 0}
];

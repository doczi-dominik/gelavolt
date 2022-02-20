package game.garbage;

import utils.Geometry;

enum GarbageIcon {
	SMALL;
	LARGE;
	ROCK;
	STAR;
	MOON;
	CROWN;
	COMET;
}

final GARBAGE_ICON_GEOMETRIES: Map<GarbageIcon, Geometry> = [
	SMALL => {
		x: 128,
		y: 680,
		width: 64,
		height: 64
	},
	LARGE => {
		x: 192,
		y: 680,
		width: 64,
		height: 64
	},
	ROCK => {
		x: 256,
		y: 680,
		width: 64,
		height: 64
	},
	STAR => {
		x: 320,
		y: 680,
		width: 64,
		height: 64
	},
	MOON => {
		x: 384,
		y: 680,
		width: 64,
		height: 64
	},
	CROWN => {
		x: 448,
		y: 680,
		width: 64,
		height: 64
	},
	COMET => {
		x: 512,
		y: 680,
		width: 104,
		height: 96
	}
];

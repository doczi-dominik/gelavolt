package input;

import utils.Geometry;

// Keys are pre-calculated `AxisMapping.hashCode()` values
final AXIS_SPRITE_COORDINATES: Map<Int, Geometry> = [
	-1 => {
		x: 384,
		y: 128,
		width: 64,
		height: 64
	},
	1 => {
		x: 448,
		y: 128,
		width: 64,
		height: 64
	},
	15 => {
		x: 512,
		y: 0,
		width: 64,
		height: 64
	},
	17 => {
		x: 576,
		y: 0,
		width: 64,
		height: 64
	},
	31 => {
		x: 640,
		y: 0,
		width: 64,
		height: 64
	},
	33 => {
		x: 512,
		y: 64,
		width: 64,
		height: 64
	},
	47 => {
		x: 576,
		y: 64,
		width: 64,
		height: 64
	},
	49 => {
		x: 640,
		y: 64,
		width: 64,
		height: 64
	}
];

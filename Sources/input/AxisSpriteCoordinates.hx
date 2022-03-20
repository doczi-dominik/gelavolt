package input;

import utils.Geometry;

// Int Keys are pre-calculated `AxisMapping.hashCode()` values
final AXIS_SPRITE_COORDINATES: Map<GamepadBrand, Map<Int, Geometry>> = [
	DS4 => [
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
	],
	SW_PRO => [
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
	],
	JOYCON => [
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
	],
	XBONE => [
		-1 => {
			x: 640,
			y: 256,
			width: 64,
			height: 64
		},
		1 => {
			x: 512,
			y: 320,
			width: 64,
			height: 64
		},
		15 => {
			x: 576,
			y: 320,
			width: 64,
			height: 64
		},
		17 => {
			x: 640,
			y: 320,
			width: 64,
			height: 64
		},
		31 => {
			x: 512,
			y: 384,
			width: 64,
			height: 64
		},
		33 => {
			x: 576,
			y: 384,
			width: 64,
			height: 64
		},
		47 => {
			x: 640,
			y: 384,
			width: 64,
			height: 64
		},
		49 => {
			x: 512,
			y: 448,
			width: 64,
			height: 64
		}
	],
	XB360 => [
		-1 => {
			x: 512,
			y: 128,
			width: 64,
			height: 64
		},
		1 => {
			x: 576,
			y: 128,
			width: 64,
			height: 64
		},
		15 => {
			x: 640,
			y: 128,
			width: 64,
			height: 64
		},
		17 => {
			x: 512,
			y: 192,
			width: 64,
			height: 64
		},
		31 => {
			x: 576,
			y: 192,
			width: 64,
			height: 64
		},
		33 => {
			x: 640,
			y: 192,
			width: 64,
			height: 64
		},
		47 => {
			x: 512,
			y: 256,
			width: 64,
			height: 64
		},
		49 => {
			x: 576,
			y: 256,
			width: 64,
			height: 64
		}
	],
];

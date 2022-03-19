package input;

import utils.Geometry;

final BUTTON_SPRITE_COORDINATES: Map<GamepadBrand, Map<GamepadButton, Geometry>> = [
	DS4 => [
		CROSS => {
			x: 0,
			y: 0,
			width: 64,
			height: 64
		},
		CIRCLE => {
			x: 64,
			y: 0,
			width: 64,
			height: 64
		},
		SQUARE => {
			x: 128,
			y: 0,
			width: 64,
			height: 64
		},
		TRIANGLE => {
			x: 192,
			y: 0,
			width: 64,
			height: 64
		},
		L1 => {
			x: 256,
			y: 0,
			width: 64,
			height: 64
		},
		R1 => {
			x: 320,
			y: 0,
			width: 64,
			height: 64
		},
		L2 => {
			x: 384,
			y: 0,
			width: 64,
			height: 64
		},
		R2 => {
			x: 448,
			y: 0,
			width: 64,
			height: 64
		},
		SHARE => {
			x: 384,
			y: 64,
			width: 128,
			height: 64
		},
		OPTIONS => {
			x: 256,
			y: 64,
			width: 128,
			height: 64
		},
		DPAD_UP => {
			x: 192,
			y: 128,
			width: 64,
			height: 64
		},
		DPAD_DOWN => {
			x: 256,
			y: 128,
			width: 64,
			height: 64
		},
		DPAD_LEFT => {
			x: 64,
			y: 128,
			width: 64,
			height: 64
		},
		DPAD_RIGHT => {
			x: 128,
			y: 128,
			width: 64,
			height: 64
		}
	]
];

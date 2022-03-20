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
		L3 => {
			x: 128,
			y: 64,
			width: 64,
			height: 64
		},
		R3 => {
			x: 192,
			y: 64,
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
	],
	SW_PRO => [
		CROSS => {
			x: 64,
			y: 192,
			width: 64,
			height: 64
		},
		CIRCLE => {
			x: 0,
			y: 192,
			width: 64,
			height: 64
		},
		SQUARE => {
			x: 192,
			y: 192,
			width: 64,
			height: 64
		},
		TRIANGLE => {
			x: 128,
			y: 192,
			width: 64,
			height: 64
		},
		L1 => {
			x: 256,
			y: 192,
			width: 64,
			height: 64
		},
		R1 => {
			x: 320,
			y: 192,
			width: 64,
			height: 64
		},
		L2 => {
			x: 384,
			y: 192,
			width: 64,
			height: 64
		},
		R2 => {
			x: 448,
			y: 192,
			width: 64,
			height: 64
		},
		L3 => {
			x: 0,
			y: 256,
			width: 64,
			height: 64
		},
		R3 => {
			x: 64,
			y: 256,
			width: 64,
			height: 64
		},
		SHARE => {
			x: 320,
			y: 320,
			width: 64,
			height: 64
		},
		OPTIONS => {
			x: 384,
			y: 320,
			width: 64,
			height: 64
		},
		DPAD_UP => {
			x: 192,
			y: 320,
			width: 64,
			height: 64
		},
		DPAD_DOWN => {
			x: 256,
			y: 320,
			width: 64,
			height: 64
		},
		DPAD_LEFT => {
			x: 64,
			y: 320,
			width: 64,
			height: 64
		},
		DPAD_RIGHT => {
			x: 128,
			y: 320,
			width: 64,
			height: 64
		}
	],
	JOYCON => [
		CROSS => {
			x: 64,
			y: 192,
			width: 64,
			height: 64
		},
		CIRCLE => {
			x: 0,
			y: 192,
			width: 64,
			height: 64
		},
		SQUARE => {
			x: 192,
			y: 192,
			width: 64,
			height: 64
		},
		TRIANGLE => {
			x: 128,
			y: 192,
			width: 64,
			height: 64
		},
		L1 => {
			x: 256,
			y: 192,
			width: 64,
			height: 64
		},
		R1 => {
			x: 320,
			y: 192,
			width: 64,
			height: 64
		},
		L2 => {
			x: 384,
			y: 192,
			width: 64,
			height: 64
		},
		R2 => {
			x: 448,
			y: 192,
			width: 64,
			height: 64
		},
		L3 => {
			x: 0,
			y: 256,
			width: 64,
			height: 64
		},
		R3 => {
			x: 64,
			y: 256,
			width: 64,
			height: 64
		},
		SHARE => {
			x: 320,
			y: 320,
			width: 64,
			height: 64
		},
		OPTIONS => {
			x: 384,
			y: 320,
			width: 64,
			height: 64
		},
		DPAD_UP => {
			x: 192,
			y: 384,
			width: 64,
			height: 64
		},
		DPAD_DOWN => {
			x: 256,
			y: 384,
			width: 64,
			height: 64
		},
		DPAD_LEFT => {
			x: 64,
			y: 384,
			width: 64,
			height: 64
		},
		DPAD_RIGHT => {
			x: 128,
			y: 384,
			width: 64,
			height: 64
		}
	],
	XBONE => [
		CROSS => {
			x: 0,
			y: 640,
			width: 64,
			height: 64
		},
		CIRCLE => {
			x: 64,
			y: 640,
			width: 64,
			height: 64
		},
		SQUARE => {
			x: 128,
			y: 640,
			width: 64,
			height: 64
		},
		TRIANGLE => {
			x: 192,
			y: 640,
			width: 64,
			height: 64
		},
		L1 => {
			x: 256,
			y: 640,
			width: 64,
			height: 64
		},
		R1 => {
			x: 320,
			y: 640,
			width: 64,
			height: 64
		},
		L2 => {
			x: 384,
			y: 640,
			width: 64,
			height: 64
		},
		R2 => {
			x: 448,
			y: 640,
			width: 64,
			height: 64
		},
		L3 => {
			x: 0,
			y: 704,
			width: 64,
			height: 64
		},
		R3 => {
			x: 64,
			y: 704,
			width: 64,
			height: 64
		},
		SHARE => {
			x: 128,
			y: 704,
			width: 64,
			height: 64
		},
		OPTIONS => {
			x: 192,
			y: 704,
			width: 64,
			height: 64
		},
		DPAD_UP => {
			x: 192,
			y: 768,
			width: 64,
			height: 64
		},
		DPAD_DOWN => {
			x: 256,
			y: 768,
			width: 64,
			height: 64
		},
		DPAD_LEFT => {
			x: 64,
			y: 768,
			width: 64,
			height: 64
		},
		DPAD_RIGHT => {
			x: 128,
			y: 768,
			width: 64,
			height: 64
		}
	],
	XB360 => [
		CROSS => {
			x: 0,
			y: 448,
			width: 64,
			height: 64
		},
		CIRCLE => {
			x: 64,
			y: 448,
			width: 64,
			height: 64
		},
		SQUARE => {
			x: 128,
			y: 448,
			width: 64,
			height: 64
		},
		TRIANGLE => {
			x: 192,
			y: 448,
			width: 64,
			height: 64
		},
		L1 => {
			x: 256,
			y: 448,
			width: 64,
			height: 64
		},
		R1 => {
			x: 320,
			y: 448,
			width: 64,
			height: 64
		},
		L2 => {
			x: 384,
			y: 448,
			width: 64,
			height: 64
		},
		R2 => {
			x: 448,
			y: 448,
			width: 64,
			height: 64
		},
		L3 => {
			x: 0,
			y: 512,
			width: 64,
			height: 64
		},
		R3 => {
			x: 64,
			y: 512,
			width: 64,
			height: 64
		},
		SHARE => {
			x: 128,
			y: 512,
			width: 64,
			height: 64
		},
		OPTIONS => {
			x: 192,
			y: 512,
			width: 64,
			height: 64
		},
		DPAD_UP => {
			x: 192,
			y: 576,
			width: 64,
			height: 64
		},
		DPAD_DOWN => {
			x: 256,
			y: 576,
			width: 64,
			height: 64
		},
		DPAD_LEFT => {
			x: 64,
			y: 576,
			width: 64,
			height: 64
		},
		DPAD_RIGHT => {
			x: 128,
			y: 576,
			width: 64,
			height: 64
		}
	]
];

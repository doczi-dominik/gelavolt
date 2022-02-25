package ui;

import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import input.KeyCodeToString.KEY_CODE_TO_STRING;
import game.actions.ActionCategory;
import input.InputDeviceManager;
import kha.Assets;
import kha.Font;
import input.IInputDeviceManager;
import haxe.ds.GenericStack;
import kha.graphics2.Graphics;

class Menu {
	static inline final HEADER_FONT_SIZE = 128;
	static inline final CONTROLS_FONT_SIZE = 64;
	static inline final WARNING_FONT_SIZE = 24;
	static inline final PADDING = 64;
	static final WARNING = [
		"BEWARE! This Is A Pre-Alpha Build of GelaVolt.",
		"Everything Is Subject To Change. Expect Bugs and Crashes.",
		"Thank You For Trying GelaVolt! Please Consider Leaving",
		"Feedback On The Official Server! :)"
	];

	final pages: GenericStack<IMenuPage>;
	final headerFont: Font;
	final controlsFont: Font;

	var headerFontSize: Int;
	var headerFontHeight: Float;
	var controlsFontSize: Int;
	var controlsFontHeight: Float;
	var warningFontSize: Int;
	var warningFontHeight: Float;
	var warningFontWidths: Array<Float>;

	public var padding(default, null): Float;
	public var inputManager(default, null): InputDeviceManager;

	public function new(initialPage: IMenuPage) {
		pages = new GenericStack();
		pages.add(initialPage);

		headerFont = Assets.fonts.DigitalDisco;
		controlsFont = Assets.fonts.Pixellari;

		ScaleManager.addOnResizeCallback(resize);
	}

	function resize() {
		final ssc = ScaleManager.smallerScale;

		headerFontSize = Std.int(HEADER_FONT_SIZE * ssc);
		headerFontHeight = headerFont.height(headerFontSize);
		controlsFontSize = Std.int(CONTROLS_FONT_SIZE * ssc);
		controlsFontHeight = controlsFont.height(controlsFontSize);
		warningFontSize = Std.int(WARNING_FONT_SIZE * ssc);
		warningFontHeight = controlsFont.height(warningFontSize);
		warningFontWidths = [];

		for (line in WARNING) {
			warningFontWidths.push(controlsFont.width(warningFontSize, line));
		}

		padding = PADDING * ssc;

		for (p in pages) {
			p.onResize();
		}
	}

	function renderKeyboardControls(g: Graphics) {
		final mappings = inputManager.inputOptions.mappings[MENU];

		var x = padding;

		for (d in pages.first().controlDisplays) {
			var str = "";

			for (key in d.actions) {
				str += '${KEY_CODE_TO_STRING[mappings[key].keyboardInput]}/';
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';

			final strWidth = controlsFont.width(controlsFontSize, str);

			g.drawString(str, x, ScaleManager.height - headerFontHeight);

			x += strWidth;
		}
	}

	function renderGamepadControls(g: Graphics) {
		final ssc = ScaleManager.smallerScale;
		final mappings = inputManager.inputOptions.mappings[MENU];

		final y = ScaleManager.height - headerFontHeight;

		var x = padding;

		for (d in pages.first().controlDisplays) {
			var str = "";

			for (key in d.actions) {
				final spr = GAMEPAD_SPRITE_COORDINATES[mappings[key].gamepadInput];

				inputManager.renderGamepadIcon(g, x, y, spr, controlsFontHeight / spr.height);

				x += spr.width * ssc;
			}

			// Hackerman but it beats having to calculate with scaling
			str += ': ${d.description}    ';

			final strWidth = g.font.width(controlsFontSize, str);

			g.drawString(str, x, y);

			x += strWidth;
		}
	}

	public function onShow(inputManager: InputDeviceManager) {
		this.inputManager = inputManager;

		pages.first().onShow(this);
	}

	public function pushPage(page: IMenuPage) {
		page.onResize();
		page.onShow(this);
		pages.add(page);
	}

	public function popPage() {
		// This seems very hackerman but there's no easier way (that I know
		// of) to check if the stack only has one element, so...
		final poppedPage = pages.pop();

		if (pages.isEmpty()) {
			pages.add(poppedPage);
		}
	}

	public function update() {
		pages.first().update();
	}

	public function render(g: Graphics, alpha: Float) {
		final currentPage = pages.first();

		g.font = headerFont;
		g.fontSize = headerFontSize;

		g.drawString(currentPage.header, padding, padding);

		final topLineY = padding + headerFontHeight;

		g.drawLine(padding, topLineY, ScaleManager.width - padding, topLineY, 4);

		currentPage.render(g, padding, topLineY + padding * 0.375);

		g.font = controlsFont;
		g.fontSize = warningFontSize;
		g.color = Color.fromValue(0xFF777777);

		final warningBaseline = ScaleManager.height - headerFontHeight * 1.5;

		for (i in 0...4) {
			final invertedIndex = 3 - i;
			g.drawString(WARNING[invertedIndex], ScaleManager.width
				- padding
				- warningFontWidths[invertedIndex], warningBaseline
				- i * warningFontHeight);
		}

		g.fontSize = controlsFontSize;
		g.color = White;

		switch (InputDeviceManager.lastDevice) {
			case KEYBOARD:
				renderKeyboardControls(g);
			case GAMEPAD:
				renderGamepadControls(g);
		}
	}
}

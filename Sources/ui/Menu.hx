package ui;

import input.IInputDevice;
import kha.Assets;
import kha.Font;
import haxe.ds.GenericStack;
import kha.graphics2.Graphics;

class Menu {
	static inline final HEADER_FONT_SIZE = 128;
	static inline final CONTROLS_FONT_SIZE = 48;
	static inline final WARNING_FONT_SIZE = 24;
	static inline final PADDING = 64;
	static final WARNING = [
		"BEWARE! This Is A Pre-Alpha Build of GelaVolt.",
		"Everything Is Subject To Change. Expect Bugs and Crashes.",
		"Thank You For Trying GelaVolt! Please Consider Leaving",
		"Feedback On The Official Server! :)"
	];

	final pages: GenericStack<IMenuPage>;
	final inputDevices: GenericStack<IInputDevice>;
	final headerFont: Font;
	final controlsFont: Font;

	var headerFontSize: Int;
	var headerFontHeight: Float;
	var controlsFontSize: Int;
	var warningFontSize: Int;
	var warningFontHeight: Float;
	var warningFontWidths: Array<Float>;

	public var padding(default, null): Float;
	public var inputDevice(default, null): IInputDevice;

	public function new(initialPage: IMenuPage) {
		pages = new GenericStack();
		pages.add(initialPage);

		inputDevices = new GenericStack();

		headerFont = Assets.fonts.DigitalDisco;
		controlsFont = Assets.fonts.Pixellari;

		ScaleManager.addOnResizeCallback(resize);
	}

	function resize() {
		final ssc = ScaleManager.smallerScale;

		headerFontSize = Std.int(HEADER_FONT_SIZE * ssc);
		headerFontHeight = headerFont.height(headerFontSize);
		controlsFontSize = Std.int(CONTROLS_FONT_SIZE * ssc);
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

	function setInputDevice() {
		inputDevice = inputDevices.first();
	}

	public function onShow(inputDevice: IInputDevice) {
		pushInputDevice(inputDevice);

		final page = pages.first();

		page.onShow(this);
		page.onResize();
	}

	public function pushPage(page: IMenuPage) {
		page.onShow(this);
		page.onResize();
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

	public inline function pushInputDevice(inputDevice: IInputDevice) {
		inputDevices.add(inputDevice);
		setInputDevice();
	}

	public inline function popInputDevice() {
		inputDevices.pop();
		setInputDevice();
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

		g.color = White;

		g.fontSize = controlsFontSize;
		inputDevice.renderControls(g, padding, pages.first().controlDisplays);
	}
}

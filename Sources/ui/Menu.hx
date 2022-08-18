package ui;

import save_data.PrefsSettings;
import input.IInputDevice;
import kha.Assets;
import kha.Font;
import haxe.ds.GenericStack;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(Menu))
class MenuOptions {
	@:optional public final initialPage: Null<IMenuPage>;
}

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

	@inject final positionFactor: Float;
	@inject final widthFactor: Float;
	@inject final backgroundOpacity: Float;

	@inject public final prefsSettings: PrefsSettings;

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
	var renderX: Float;

	public final scaleManager: ScaleManager;

	public var padding(default, null): Float;
	public var inputDevice(default, null): IInputDevice;

	public function new(opts: MenuOptions) {
		game.Macros.initFromOpts();

		pages = new GenericStack();

		if (opts.initialPage != null)
			pages.add(opts.initialPage);

		inputDevices = new GenericStack();
		headerFont = Assets.fonts.DigitalDisco;
		controlsFont = Assets.fonts.Pixellari;

		scaleManager = new ScaleManager(ScaleManager.SCREEN_DESIGN_WIDTH, ScaleManager.SCREEN_DESIGN_HEIGHT);

		ScaleManager.addOnResizeCallback(resize);
	}

	function resize() {
		final scr = ScaleManager.screen;

		scaleManager.resize(scr.width * widthFactor, scr.height);

		final ssc = scaleManager.smallerScale;

		headerFontSize = Std.int(HEADER_FONT_SIZE * ssc);
		headerFontHeight = headerFont.height(headerFontSize);
		controlsFontSize = Std.int(CONTROLS_FONT_SIZE * ssc);
		warningFontSize = Std.int(WARNING_FONT_SIZE * ssc);
		warningFontHeight = controlsFont.height(warningFontSize);
		warningFontWidths = [];

		for (line in WARNING) {
			warningFontWidths.push(controlsFont.width(warningFontSize, line));
		}

		renderX = scr.width * positionFactor;

		padding = PADDING * ssc;

		for (p in pages) {
			p.onShow(this);
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

		final firstPage = pages.first();

		firstPage.onShow(this);
		firstPage.onResize();
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
		final currentPage = pages.first();

		if (currentPage == null)
			return;

		currentPage.update();
	}

	public function render(g: Graphics, alpha: Float) {
		final currentPage = pages.first();

		if (currentPage == null)
			return;

		final paddedX = renderX + padding;
		final width = scaleManager.width;
		final height = scaleManager.height;

		g.scissor(Std.int(renderX), 0, Std.int(width), Std.int(height));

		g.pushOpacity(backgroundOpacity);
		g.color = Black;
		g.fillRect(renderX, 0, width, height);
		g.color = White;
		g.popOpacity();

		g.font = headerFont;
		g.fontSize = headerFontSize;

		g.drawString(currentPage.header, paddedX, padding);

		final topLineY = padding + headerFontHeight;

		g.drawLine(paddedX, topLineY, renderX + width - padding, topLineY, 4);

		currentPage.render(g, paddedX, topLineY + padding * 0.375);

		g.font = controlsFont;
		g.fontSize = warningFontSize;
		g.color = Color.fromValue(0xFF777777);

		final warningBaseline = scaleManager.height - headerFontHeight * 1.5;

		for (i in 0...4) {
			final invertedIndex = 3 - i;
			g.drawString(WARNING[invertedIndex], renderX
				+ width
				- padding
				- warningFontWidths[invertedIndex], warningBaseline
				- i * warningFontHeight);
		}

		g.color = White;

		g.fontSize = controlsFontSize;
		inputDevice.renderControls(g, renderX, width, padding, currentPage.controlHints);

		g.disableScissor();
	}
}

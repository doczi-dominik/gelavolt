package ui;

import utils.Utils;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(ListMenuPage))
class ListMenuPageOptions {}

class ListMenuPage implements IMenuPage {
	static inline final DESC_FONT_SIZE = 48;
	static inline final MAX_WIDGETS_PER_VIEW = 7;
	static inline final WIDGET_BOTTOM_PADDING = 16;
	static final DEFAULT_CONTROL_DISPLAYS: Array<ControlHint> = [
		{actions: [MENU_UP, MENU_DOWN], description: "Select"},
		{actions: [BACK], description: "Back"},
	];

	@inject final widgetBuilder: Menu->Array<IListWidget>;

	@inject public final header: String;

	final font: Font;

	var menu: Menu;

	var widgetBottomPadding: Float;

	var descFontSize: Int;
	var descFontHeight: Float;
	var scrollArrowSize: Float;

	var widgets: Array<IListWidget>;
	var widgetIndex: Int;
	var minIndex: Int;

	public var controlHints(default, null): Array<ControlHint>;

	public function new(opts: ListMenuPageOptions) {
		game.Macros.initFromOpts();

		font = Assets.fonts.Pixellari;

		widgets = [];
		widgetIndex = 0;
		minIndex = 0;
	}

	inline function setControlHints() {
		controlHints = DEFAULT_CONTROL_DISPLAYS.concat(widgets[widgetIndex].controlHints);
	}

	function onSelect() {
		widgetIndex = Utils.intClamp(0, widgetIndex, widgets.length - 1);
		setControlHints();
	}

	function popPage() {
		menu.popPage();
	}

	function renderArrow(g: Graphics, x: Float, y: Float, spriteX: Int) {
		g.drawScaledSubImage(Assets.images.Arrows, spriteX, 0, 64, 64, x, y, scrollArrowSize, scrollArrowSize);
	}

	public function onResize() {
		final smallerScale = menu.scaleManager.smallerScale;

		widgetBottomPadding = WIDGET_BOTTOM_PADDING * smallerScale;

		descFontSize = Std.int(DESC_FONT_SIZE * smallerScale);
		descFontHeight = font.height(descFontSize);
		scrollArrowSize = 64 * smallerScale;

		for (w in widgets) {
			w.onResize();
		}
	}

	inline function moveUp() {
		if (widgetIndex > 0) {
			widgetIndex--;

			if (widgetIndex < minIndex) {
				minIndex--;
			}
		} else {
			widgetIndex = widgets.length - 1;
			minIndex = Std.int(Math.max(0, widgets.length - MAX_WIDGETS_PER_VIEW));
		}

		onSelect();
	}

	inline function moveDown() {
		if (widgetIndex < widgets.length - 1) {
			widgetIndex++;

			if (widgetIndex > minIndex + MAX_WIDGETS_PER_VIEW - 1) {
				minIndex++;
			}
		} else {
			widgetIndex = 0;
			minIndex = 0;
		}

		onSelect();
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		widgets = widgetBuilder(menu);

		for (w in widgets) {
			w.onShow(menu);
		}

		if (!menu.prefsSettings.menuRememberCursor) {
			widgetIndex = 0;
			minIndex = 0;
		}

		setControlHints();
	}

	public function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(MENU_UP)) {
			moveUp();
		} else if (inputDevice.getAction(MENU_DOWN)) {
			moveDown();
		}

		if (inputDevice.getAction(BACK)) {
			popPage();
		}

		widgets[widgetIndex].update();
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = descFontSize;

		if (minIndex > 0) {
			renderArrow(g, x, y, 64);
		}

		var drawY = y + scrollArrowSize;

		for (i in 0...MAX_WIDGETS_PER_VIEW) {
			final index = minIndex + i;
			final widget = widgets[index];

			if (widget == null)
				break;

			widget.render(g, x, drawY, index == widgetIndex);
			drawY += widget.height + widgetBottomPadding;
		}

		g.font = font;
		g.fontSize = descFontSize;

		if (minIndex + MAX_WIDGETS_PER_VIEW < widgets.length) {
			renderArrow(g, x, drawY, 0);
		}

		final desc = widgets[widgetIndex].description;

		for (i in 0...desc.length) {
			final row = desc[i];

			final rowWidth = font.width(descFontSize, row);

			g.drawString(row, x + menu.scaleManager.width - menu.padding * 2 - rowWidth, y + descFontHeight * i);
		}
	}
}

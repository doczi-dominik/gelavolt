package ui;

import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;

class ListMenuPage implements IMenuPage {
	static inline final DESC_FONT_SIZE = 48;
	static inline final MAX_WIDGETS_PER_VIEW = 10;
	static inline final WIDGET_BOTTOM_PADDING = 16;
	static final DEFAULT_CONTROL_DISPLAYS: Array<ControlDisplay> = [
		{actions: [MENU_UP, MENU_DOWN], description: "Select"},
		{actions: [BACK], description: "Back"},
	];

	final font: Font;
	final widgetBuilder: Menu->Array<IListWidget>;

	var menu: Menu;

	var widgetBottomPadding: Float;

	var descFontSize: Int;
	var descFontHeight: Float;

	var widgets: Array<IListWidget>;
	var widgetIndex: Int;
	var minIndex: Int;

	public final header: String;

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new(opts: ListMenuPageOptions) {
		header = opts.header;
		widgetBuilder = opts.widgetBuilder;

		font = Assets.fonts.Pixellari;

		widgets = [];
		widgetIndex = 0;
		minIndex = 0;
	}

	function onSelect() {
		controlDisplays = DEFAULT_CONTROL_DISPLAYS.concat(widgets[widgetIndex].controlDisplays);
	}

	function popPage() {
		menu.popPage();
	}

	public function onResize() {
		final smallerScale = ScaleManager.smallerScale;

		widgetBottomPadding = WIDGET_BOTTOM_PADDING * smallerScale;

		descFontSize = Std.int(DESC_FONT_SIZE * smallerScale);
		descFontHeight = font.height(descFontSize);

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
			minIndex = Std.int(Math.max(0, widgetIndex - MAX_WIDGETS_PER_VIEW));
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

		onSelect();
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
		for (i in 0...MAX_WIDGETS_PER_VIEW) {
			final index = minIndex + i;
			final widget = widgets[index];

			if (widget == null)
				break;

			final widgetY = y + (widget.height + widgetBottomPadding) * i;

			widget.render(g, x, widgetY, index == widgetIndex);
		}

		g.font = font;
		g.fontSize = descFontSize;

		final desc = widgets[widgetIndex].description;

		final padding = menu.padding;
		final rightBorder = ScaleManager.width - padding;

		for (i in 0...desc.length) {
			final row = desc[i];

			final rowWidth = font.width(descFontSize, row);

			g.drawString(row, rightBorder - rowWidth, y + descFontHeight * i);
		}
	}
}

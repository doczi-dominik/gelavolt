package ui;

import kha.graphics2.Graphics;
import kha.Assets;
import haxe.ds.ReadOnlyArray;
import kha.Font;

@:structInit
class MenuPageBaseOptions {
	public final designFontSize: Int;
	public final header: String;
	public final controlHints: ReadOnlyArray<ControlHint>;

	@:optional public final font = "Pixellari";
}

class MenuPageBase implements IMenuPage {
	final designFontSize: Int;
	final font: Font;

	public final header: String;
	public var controlHints(default, null): ReadOnlyArray<ControlHint>;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;

	public function new(opts: MenuPageBaseOptions) {
		designFontSize = opts.designFontSize;
		font = Assets.fonts.get(opts.font);

		header = opts.header;
		controlHints = opts.controlHints;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function onResize() {
		fontSize = Std.int(designFontSize * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function update() {}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;
	}
}

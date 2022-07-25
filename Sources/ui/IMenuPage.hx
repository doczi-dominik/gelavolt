package ui;

import kha.graphics2.Graphics;

interface IMenuPage {
	public final header: String;

	public var controlHints(default, null): Array<ControlHint>;

	public function onResize(): Void;
	public function onShow(menu: Menu): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float): Void;
}

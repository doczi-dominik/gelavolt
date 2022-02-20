package ui;

import kha.graphics2.Graphics;

interface IMenuPage {
	public final header: String;

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function onResize(): Void;
	public function onShow(menu: Menu): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float): Void;
}

package ui;

import kha.graphics2.Graphics;

interface IListWidget {
	public var description(default, null): Array<String>;
	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function onShow(menu: Menu): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool): Void;
}

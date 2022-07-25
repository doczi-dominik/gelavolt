package ui;

import kha.graphics2.Graphics;

interface IListWidget {
	public var description(default, null): Array<String>;
	public var controlHints(default, null): Array<ControlHint>;
	public var height(default, null): Float;

	public function onShow(menu: Menu): Void;
	public function onResize(): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float, isSelected: Bool): Void;
}

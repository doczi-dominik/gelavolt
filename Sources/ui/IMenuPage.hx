package ui;

import haxe.ds.ReadOnlyArray;
import kha.graphics2.Graphics;

interface IMenuPage {
	public final header: String;

	public var controlHints(default, null): ReadOnlyArray<ControlHint>;

	public function onResize(): Void;
	public function onShow(menu: Menu): Void;

	public function update(): Void;
	public function render(g: Graphics, x: Float, y: Float): Void;
}

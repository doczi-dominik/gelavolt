import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

interface IScreen {
	public function dispose(): Void;
	public function update(): Void;
	public function render(g: Graphics, g4: Graphics4, alpha: Float): Void;
}

package game.ui;

import ui.MenuPageBase;
import utils.Point;
import kha.math.FastMatrix3;
import game.gelos.Gelo;
import game.Queue;
import kha.graphics2.Graphics;
import utils.Utils.negativeMod;

@:structInit
@:build(game.Macros.buildOptionsClass(QueueEditorPage))
class QueueEditorPageOptions {}

class QueueEditorPage extends MenuPageBase {
	@inject final queue: Queue;
	@inject final groupEditor: GroupEditorPage;

	var selectionX: Int;
	var selectionY: Int;

	var minView: Int;

	public function new(opts: QueueEditorPageOptions) {
		super({
			designFontSize: 72,
			header: "Edit Queue",
			controlHints: [
				{actions: [MENU_LEFT, MENU_UP, MENU_DOWN, MENU_RIGHT], description: "Select"},
				{actions: [BACK], description: "Back"},
				{actions: [CONFIRM], description: "Edit"}
			]
		});

		game.Macros.initFromOpts();

		selectionX = 0;
		selectionY = 0;

		minView = 0;
	}

	function cellToScreen(cellX: Int, cellY: Int): Point {
		return {
			x: 150 + cellX * Gelo.SIZE * 4,
			y: 118 + cellY * Gelo.SIZE * 4.5
		};
	}

	function selectionToIndex() {
		return selectionY * 7 + selectionX;
	}

	function selectHorizontal(delta: Int) {
		final groupCount = queue.groups.data.length;

		final d = selectionY * -7 + groupCount;
		final mod = Std.int(Math.min(d, 7));

		selectionX = Std.int(negativeMod(selectionX + delta, mod));
	}

	function selectVertical(delta: Int) {
		selectionY = Std.int(negativeMod(selectionY + delta, Std.int(queue.groups.data.length / 7) + 1));
	}

	override function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(MENU_LEFT)) {
			selectHorizontal(-1);
		} else if (inputDevice.getAction(MENU_RIGHT)) {
			selectHorizontal(1);
		}

		final groupCount = queue.groups.data.length;
		final maxRows = Std.int(groupCount / 7);
		final currentRow = Std.int(minView / 7);

		// TODO: Refactor this ugly ass input handling
		if (inputDevice.getAction(MENU_UP)) {
			if (selectionY > 0) {
				selectVertical(-1);

				if (selectionY < currentRow) {
					minView -= 7;
				}
			} else {
				selectionY = maxRows;
				minView = (maxRows - 1) * 7;
			}
			selectHorizontal(0);
		} else if (inputDevice.getAction(MENU_DOWN)) {
			if (selectionY < maxRows) {
				selectVertical(1);

				if (selectionY > currentRow + 1) {
					minView += 7;
				}
			} else {
				selectionY = 0;
				minView = 0;
			}
			selectHorizontal(0);
		}

		if (inputDevice.getAction(BACK)) {
			menu.popPage();
		} else if (inputDevice.getAction(CONFIRM)) {
			groupEditor.loadGroup(selectionToIndex());
			menu.pushPage(groupEditor);
		}
	}

	override function render(g: Graphics, x: Float, y: Float) {
		super.render(g, x, y);

		final groups = queue.groups;
		final scale = menu.scaleManager.smallerScale;
		final transform = FastMatrix3.translation(x, y).multmat(FastMatrix3.scale(scale, scale));

		g.pushTransformation(g.transformation.multmat(transform));

		final selectedIndex = selectionToIndex();

		for (i in 0...14) {
			final index = minView + i;
			final group = groups.data[index];

			if (group == null)
				break;

			final row = Std.int(i / 7);
			final column = i % 7;

			final screenCoords = cellToScreen(column, row);
			final screenX = screenCoords.x;
			final screenY = screenCoords.y;

			group.render(g, screenX, screenY);

			final str = '${index + 1}.';

			if (index == selectedIndex) {
				g.color = Orange;
				g.drawRect(screenX - Gelo.SIZE * 2, screenY - Gelo.SIZE * 2, Gelo.SIZE * 4, Gelo.SIZE * 4.5, 4);
			}

			g.drawString(str, screenX - g.font.width(fontSize, str) / 2, screenY + Gelo.SIZE * 1.5);

			g.color = White;
		}

		g.popTransformation();
	}
}

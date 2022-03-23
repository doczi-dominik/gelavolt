package game.ui;

import kha.Color;
import ui.ControlDisplay;
import game.gelos.Gelo;
import kha.math.FastMatrix3;
import ui.Menu;
import game.Queue;
import kha.graphics2.Graphics;
import ui.IMenuPage;
import utils.Utils.negativeMod;

class GroupEditorPage implements IMenuPage {
	static final GRID_COLOR = Color.fromValue(0xff444444);

	final queue: Queue;

	var menu: Menu;
	var currentIndex: Int;
	var scale: Float;

	var selectionX: Int;
	var selectionY: Int;

	public final header = "Edit Gelo Group";

	public final controlDisplays: Array<ControlDisplay> = [
		{actions: [MENU_LEFT, MENU_UP, MENU_DOWN, MENU_RIGHT], description: "Select"},
		{actions: [BACK], description: "Back"},
		{actions: [CONFIRM], description: "Cycle Colors"}
	];

	public function new(queue: Queue) {
		this.queue = queue;

		selectionX = 1;
		selectionY = 1;
	}

	function selectHorizontal(delta: Int) {
		// selectionX = Std.int(negativeMod(selectionX + delta, 3));
	}

	function selectVertical(delta: Int) {
		selectionY = Std.int(negativeMod(selectionY + delta, 2));
	}

	public function onResize() {
		scale = menu.scaleManager.smallerScale * 4;
	}

	public function onShow(menu: Menu) {
		this.menu = menu;
	}

	public function loadGroup(index: Int) {
		currentIndex = index;
	}

	public function update() {
		final inputDevice = menu.inputDevice;

		if (inputDevice.getAction(MENU_LEFT)) {
			selectHorizontal(-1);
		} else if (inputDevice.getAction(MENU_RIGHT)) {
			selectHorizontal(1);
		}

		if (inputDevice.getAction(MENU_UP)) {
			selectVertical(-1);
		} else if (inputDevice.getAction(MENU_DOWN)) {
			selectVertical(1);
		}

		if (inputDevice.getAction(BACK)) {
			menu.popPage();
		} else if (inputDevice.getAction(CONFIRM)) {
			final group = queue.get(currentIndex);

			if (selectionX == 1 && selectionY == 1) {
				group.mainColor = Std.int(negativeMod(group.mainColor + 1, 5));
			} else {
				var positionID = selectionY * 3 + selectionX;
				if (positionID > 3)
					positionID--;

				group.others[positionID].color = Std.int(negativeMod(group.others[positionID].color + 1, 6));
			}
		}
	}

	public function render(g: Graphics, x: Float, y: Float) {
		final transform = FastMatrix3.translation(x, y).multmat(FastMatrix3.scale(scale, scale));

		g.pushTransformation(g.transformation.multmat(transform));

		final groupX = Gelo.SIZE * 3.25;
		final groupY = Gelo.SIZE * 1.5;

		final offsetX = Gelo.SIZE * 1.75;

		g.color = GRID_COLOR;

		for (i in 1...3) {
			final currentGrid = i * Gelo.SIZE;
			final verticalX = offsetX + currentGrid;
			final end = Gelo.SIZE * 3;

			g.drawLine(verticalX, 0, verticalX, end, 1);
			g.drawLine(offsetX, currentGrid, offsetX + end, currentGrid, 1);
		}

		g.color = White;

		queue.get(currentIndex).render(g, groupX, groupY);

		g.drawRect(Gelo.SIZE * 1.75 + selectionX * Gelo.SIZE, selectionY * Gelo.SIZE, Gelo.SIZE, Gelo.SIZE, 4);

		g.popTransformation();
	}
}

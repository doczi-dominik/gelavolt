package game.boardstates;

import utils.Utils;
import game.fields.IFieldMarker;
import save_data.PrefsSave;
import game.fields.ColorConflictFieldMarker;
import game.fields.DependencyFieldMarker;
import game.fields.AllClearFieldMarker;
import game.fields.ChainFieldMarker;
import game.simulation.ChainSimulator;
import game.ChainCounter;
import game.fields.Field;
import game.actions.TrainingActions;
import game.actions.MenuActions;
import game.geometries.BoardGeometries;
import game.gelos.GeloColor;
import game.gelos.Gelo;
import input.IInputDeviceManager;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import utils.Utils.intClamp;

// Making an enum abstract with casting rules allows toggling between the
// modes using `(mode + 1) % modecount`, where modecount is the number of
// values in the enum
private enum abstract Mode(Int) from Int to Int {
	final GELOS = 0;
	final MARKERS;
}

class EditingBoardState implements IBoardState {
	static final COLORS = [COLOR1, COLOR2, COLOR3, COLOR4, COLOR5, GARBAGE];

	final geometries: BoardGeometries;
	final inputManager: IInputDeviceManager;
	final chainSim: ChainSimulator;
	final chainCounter: ChainCounter;
	final prefsSave: PrefsSave;

	final markers: Array<IFieldMarker>;

	var cursorX: Int;
	var cursorY: Int;

	var cursorDisplayX: Float;
	var cursorDisplayY: Float;

	var selectedIndex: Int;

	var mode: Mode;

	public final field: Field;

	public function new(opts: EditingBoardStateOptions) {
		geometries = opts.geometries;
		inputManager = opts.inputManager;
		chainSim = opts.chainSim;
		chainCounter = opts.chainCounter;
		prefsSave = opts.prefsSave;

		markers = [
			new ChainFieldMarker(), AllClearFieldMarker.create(prefsSave, COLOR1), AllClearFieldMarker.create(prefsSave, COLOR2),
			AllClearFieldMarker.create(prefsSave, COLOR3), AllClearFieldMarker.create(prefsSave, COLOR4), AllClearFieldMarker.create(prefsSave, COLOR5),
			DependencyFieldMarker.create(prefsSave, COLOR1), DependencyFieldMarker.create(prefsSave, COLOR2), DependencyFieldMarker.create(prefsSave, COLOR3),
			DependencyFieldMarker.create(prefsSave, COLOR4), DependencyFieldMarker.create(prefsSave, COLOR5),
			ColorConflictFieldMarker.create(prefsSave, COLOR1), ColorConflictFieldMarker.create(prefsSave, COLOR2),
			ColorConflictFieldMarker.create(prefsSave, COLOR3), ColorConflictFieldMarker.create(prefsSave, COLOR4),
			ColorConflictFieldMarker.create(prefsSave, COLOR5),
		];

		field = opts.field;

		cursorX = Std.int(field.columns / 2) - 1;
		cursorY = field.totalRows - 1;

		// Set cursorDisplayX / cursorDisplayY
		moveCursor(0, 0);

		selectedIndex = 0;

		mode = GELOS;
	}

	function moveCursor(deltaX: Int, deltaY: Int) {
		cursorX = intClamp(0, cursorX + deltaX, field.columns - 1);
		cursorY = intClamp(field.garbageRows, cursorY + deltaY, field.totalRows - 1);

		final screenCoords = field.cellToScreen(cursorX, cursorY);

		cursorDisplayX = screenCoords.x - Gelo.HALFSIZE;
		cursorDisplayY = screenCoords.y - Gelo.HALFSIZE;
	}

	function changeIndex(delta: Int) {
		final modulo = (mode == GELOS) ? COLORS.length : markers.length;

		selectedIndex = Std.int(Utils.negativeMod(selectedIndex + delta, modulo));
	}

	function modifyChain() {
		chainSim.modify(field.copy());
	}

	function set() {
		switch (mode) {
			case GELOS:
				field.newGelo(cursorX, cursorY, COLORS[selectedIndex], false);
				field.setSpriteVariations();
			case MARKERS:
				field.setMarker(cursorX, cursorY, markers[selectedIndex]);
		}

		modifyChain();
	}

	function clear() {
		switch (mode) {
			case GELOS:
				field.clear(cursorX, cursorY);
				field.setSpriteVariations();
			case MARKERS:
				field.clearMarker(cursorX, cursorY);
		}

		modifyChain();
	}

	function switchMode() {
		mode = (mode + 1) % 2;

		selectedIndex = 0;
	}

	function renderCurrentSelection(g: Graphics) {
		final geloDisplay = geometries.editGeloDisplay;
		final displayX = geloDisplay.x;
		final displayY = geloDisplay.y;

		switch (mode) {
			case GELOS:
				Gelo.renderStatic(g, displayX, displayY, COLORS[selectedIndex], NONE);
			case MARKERS:
				markers[selectedIndex].render(g, displayX, displayY);
		}
	}

	public function clearField() {
		field.clearAll();
		modifyChain();
	}

	public function loadStep() {
		final step = chainSim.getViewedStep();

		field.copyFrom(step.fieldSnapshot);
	}

	public function viewPrevious() {
		chainSim.viewPrevious();
		chainSim.editViewed();
		loadStep();
	}

	public function viewNext() {
		chainSim.viewNext();
		chainSim.editViewed();
		loadStep();
	}

	public function update() {
		if (inputManager.getAction(LEFT)) {
			moveCursor(-1, 0);
		} else if (inputManager.getAction(RIGHT)) {
			moveCursor(1, 0);
		}

		if (inputManager.getAction(UP)) {
			moveCursor(0, -1);
		} else if (inputManager.getAction(DOWN)) {
			moveCursor(0, 1);
		}

		if (inputManager.getAction(PREVIOUS_COLOR)) {
			changeIndex(-1);
		} else if (inputManager.getAction(NEXT_COLOR)) {
			changeIndex(1);
		}

		if (inputManager.getAction(TOGGLE_MARKERS)) {
			switchMode();
		}

		if (inputManager.getAction(CONFIRM)) {
			set();
		} else if (inputManager.getAction(BACK)) {
			clear();
		}

		field.update();
		chainCounter.update();
	}

	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float) {
		g.color = Color.fromBytes(64, 32, 32);
		g.fillRect(0, 0, BoardGeometries.WIDTH, BoardGeometries.HEIGHT);
		g.color = White;
	}

	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float) {
		g.drawImage(Assets.images.Border, -12, -12);

		renderCurrentSelection(g);

		field.render(g, g4, alpha);

		g.drawRect(cursorDisplayX, cursorDisplayY, Gelo.SIZE, Gelo.SIZE, 8);

		chainCounter.render(g, alpha);
	}
}

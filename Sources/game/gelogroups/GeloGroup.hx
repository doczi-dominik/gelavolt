package game.gelogroups;

import game.gelos.GeloColor;
import game.gelos.OtherGelo;
import game.rules.Rule;
import save_data.PrefsSettings;
import game.fields.Field;
import kha.Color;
import game.simulation.PopSimStep;
import game.simulation.ChainSimulator;
import game.gelos.GeloPoint;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.score.ScoreManager;
import game.gelos.FieldGelo;
import game.gelos.Gelo;
import utils.Utils.lerp;
import utils.Utils.negativeMod;

using kha.graphics2.GraphicsExtension;

enum GeloGroupState {
	CONTROLLING;
	SPLITTING;
}

class GeloGroup {
	final rule: Rule;
	final prefsSettings: PrefsSettings;

	final scoreManager: ScoreManager;
	final field: Field;
	final chainSim: ChainSimulator;

	var main: Gelo;
	var others: Array<OtherGelo>;

	var x: Float;
	var y: Float;

	var prevDisplayX: Float;
	var prevDisplayY: Float;

	var displayX: Float;
	var displayY: Float;

	var prevRotationAngle: Int;

	var rotationID: Int;
	var rotationAngle: Int;

	var targetRotationAngle: Int;
	var rotationIncrement: Int;

	var stuckRotationCount: Int;
	var lockResetCount: Int;
	var graceT: Int;

	var das: Int;
	var dasDirection: Int;
	var arr: Int;

	var mainShadow: GeloPoint;
	var otherShadows: Array<GeloPoint>;

	var willTriggerChain: Bool;
	var shouldLock: Bool;
	var willTriggerChainT = 0;

	public var isVisible: Bool;
	public var isShadowVisible: Bool;

	public function new(opts: GeloGroupOptions) {
		rule = opts.rule;
		prefsSettings = opts.prefsSettings;

		scoreManager = opts.scoreManager;
		field = opts.field;
		chainSim = opts.chainSim;

		isVisible = false;
		isShadowVisible = false;
	}

	function shift(dir: Int) {
		if (lockResetCount > 7)
			return;
		if (1 < das && das < 10)
			return;
		if (arr % 2 == 0)
			return;

		final mainX = x;
		final mainY = y + Gelo.HALFSIZE;

		final nextMainX = mainX + dir * Gelo.SIZE;

		final cellCoords = field.screenToCell(nextMainX, mainY);
		final cellX = cellCoords.x;
		final cellY = cellCoords.y;

		if (checkPlacement(cellX, cellY, rotationID)) {
			x = nextMainX;
			updateShadow(cellX, cellY);
			resetLock();
			return;
		}

		final raisedCellCoords = field.screenToCell(nextMainX, y);
		final raisedCellX = raisedCellCoords.x;
		final raisedCellY = raisedCellCoords.y;

		if (checkPlacement(raisedCellX, raisedCellY, rotationID)) {
			final screenCoords = field.cellToScreen(raisedCellX, raisedCellY);

			x = nextMainX;
			y = screenCoords.y;

			updateShadow(cellX, raisedCellY);
			resetLock();
		}
	}

	function chargeDAS(dir: Int) {
		if (dasDirection != dir) {
			dasDirection = dir;
			das = 0;
			arr = 0;
		}

		das++;
		arr++;
	}

	function checkPlacement(mainCellX: Int, mainCellY: Int, rotationID: Int) {
		if (field.cannotPlace(mainCellX, mainCellY))
			return false;

		for (o in others) {
			final rot = o.getRotation(rotationID);

			if (field.cannotPlace(mainCellX + rot.x, mainCellY + rot.y))
				return false;
		}

		return true;
	}

	inline function rotationIDToAngle() {
		return Std.int(negativeMod(24 - rotationID * 24, 32));
	}

	function checkRotationAndConfirm(mainCellX: Int, mainCellY: Int, rotationID: Int) {
		if (!checkPlacement(mainCellX, mainCellY, rotationID))
			return false;

		rotationAngle = rotationIDToAngle();
		this.rotationID = rotationID;
		targetRotationAngle = rotationIDToAngle();

		for (o in others) {
			o.changeRotation(rotationID);
		}

		updateShadow(mainCellX, mainCellY);
		resetLock();

		return true;
	}

	function updateShadow(cellX: Int, cellY: Int) {
		final workField = field.copy();

		final mainGelo = workField.newGelo(cellX, cellY, main.color, true);
		final otherGelos: Array<FieldGelo> = [];

		for (o in others) {
			otherGelos.push(workField.newGelo(cellX + o.relX, cellY + o.relY, o.color, true));
		}

		workField.drop();

		mainShadow = {
			x: Std.int(mainGelo.x),
			y: Std.int(mainGelo.y),
			color: mainGelo.color
		};

		otherShadows = [];

		for (o in otherGelos) {
			otherShadows.push({
				x: Std.int(o.x),
				y: Std.int(o.y),
				color: o.color
			});
		}

		chainSim.clear();
		chainSim.simulate({
			groupData: null,
			field: workField,
			sendAllClearBonus: false,
			dropBonus: 0,
			groupIndex: null
		});

		field.forEach((gelo, _, _) -> {
			gelo.willTriggerChain = false;
		});

		willTriggerChain = false;

		if (chainSim.steps.length == 3) {
			return;
		}

		chainSim.viewNext();
		chainSim.viewNext();

		final popStep = cast(chainSim.getViewedStep(), PopSimStep);

		for (c in popStep.popInfo.clears) {
			// The clear might refer to the Gelo that is still dropping,
			// so it might be empty on the "real" field.
			if (field.isEmptyAtPoint(c))
				continue;

			field.getAtPoint(c).willTriggerChain = true;
		}

		willTriggerChain = true;
	}

	function resetLock() {
		if (graceT == 0)
			return;

		graceT = 0;
		lockResetCount++;
	}

	function rotate(dir: Int) {
		if (lockResetCount > 7)
			return;

		var nextRotationID = (rotationID + dir) & 3;

		if (stuckRotationCount % 2 == 1) {
			nextRotationID = (nextRotationID + dir) & 3;
			stuckRotationCount = 0;
		}

		final cellCoords = field.screenToCell(x, y + Gelo.HALFSIZE - 2);
		final cellX = cellCoords.x;
		final cellY = cellCoords.y;

		// Try to rotate
		if (checkRotationAndConfirm(cellX, cellY, nextRotationID)) {
			return;
		}

		// Try pushing up, except when using Tsu physics
		final raisedCellY = cellY - 1;

		if (rule.physics != TSU && checkRotationAndConfirm(cellX, raisedCellY, nextRotationID)) {
			final screenCoords = field.cellToScreen(cellX, raisedCellY);

			x = screenCoords.x;
			y = screenCoords.y;

			return;
		}

		final oppositeRotationID = nextRotationID ^ 2;

		// Check if the opposite side is free (by simulating a double rotation)
		if (checkPlacement(cellX, cellY, oppositeRotationID)) {
			for (o in others) {
				final dir = o.getRotation(oppositeRotationID);

				if (checkRotationAndConfirm(cellX + dir.x, cellY + dir.y, nextRotationID)) {
					x += dir.x * Gelo.SIZE;
					y += dir.y * Gelo.SIZE;

					return;
				}
			}
		}

		stuckRotationCount++;
	}

	function updateRotation() {
		if (rotationAngle == targetRotationAngle)
			return;

		rotationAngle = Std.int(negativeMod(rotationAngle + rotationIncrement, 32));
	}

	function updateSmoothing() {
		final distanceX = x - displayX;
		final distanceY = y - displayY;

		if (distanceX != 0) {
			displayX += Math.min(distanceX / Math.abs(distanceX) * Gelo.HALFSIZE, distanceX);
		}

		if (distanceY != 0) {
			displayY += Math.min(distanceY / Math.abs(distanceY) * Gelo.HALFSIZE, distanceY);
		}
	}

	public function load(x: Float, y: Float, opts: GeloGroupData) {
		main = Gelo.create({
			prefsSettings: prefsSettings,
			color: opts.mainColor,
		});

		others = [];

		for (o in opts.others) {
			if (o.color == EMPTY)
				continue;

			others.push(OtherGelo.create(o));
		}

		this.x = x;
		this.y = y;

		prevDisplayX = x;
		prevDisplayY = y;

		displayX = x;
		displayY = y;

		prevRotationAngle = 24;

		rotationID = 0;
		rotationAngle = 24;
		targetRotationAngle = 24;
		rotationIncrement = 0;

		stuckRotationCount = 0;
		lockResetCount = 0;
		graceT = 0;

		willTriggerChain = false;
		willTriggerChainT = 0;

		isShadowVisible = true;

		final cellCoords = field.screenToCell(x, y);
		updateShadow(cellCoords.x, cellCoords.y);
	}

	public inline function chargeDASLeft() {
		chargeDAS(-1);
	}

	public inline function chargeDASRight() {
		chargeDAS(1);
	}

	public function stopDAS() {
		dasDirection = 0;
		das = 0;
		arr = 0;
	}

	public inline function shiftLeft() {
		shift(-1);
	}

	public inline function shiftRight() {
		shift(1);
	}

	public inline function rotateLeft() {
		rotate(-1);
		rotationIncrement = -1;
	}

	public inline function rotateRight() {
		rotate(1);
		rotationIncrement = 1;
	}

	public function drop(softDrop: Bool) {
		final dropSpeed = (softDrop) ? Gelo.HALFSIZE : rule.dropSpeed;

		final nextY = y + dropSpeed;

		var collisionOccured = false;

		while (y < nextY) {
			final cellCoords = field.screenToCell(x, y + Gelo.HALFSIZE - 1);

			if (!checkPlacement(cellCoords.x, cellCoords.y, rotationID)) {
				collisionOccured = true;
				break;
			}

			y++;
		}

		// Prevents snapping to the bottom
		if (collisionOccured && prevDisplayY == displayY) {
			if (rotationAngle == targetRotationAngle && (softDrop || lockResetCount > 7 || graceT > 48)) {
				final cellCoords = field.screenToCell(x, y);
				final cellX = cellCoords.x;
				final cellY = cellCoords.y;

				field.newGelo(cellX, cellY, main.color, false).startSplitting();

				for (o in others) {
					field.newGelo(cellX + o.relX, cellY + o.relY, o.color, false).startSplitting();
				}

				isShadowVisible = false;
				isVisible = false;

				return true;
			}

			graceT++;
		} else if (softDrop) {
			scoreManager.addDropBonus();
		}

		return false;
	}

	public function hardDrop() {
		final mainCell = field.screenToCell(mainShadow.x, mainShadow.y);

		field.newGelo(mainCell.x, mainCell.y, mainShadow.color, false).startSplitting();

		for (o in otherShadows) {
			final otherCell = field.screenToCell(o.x, o.y);

			field.newGelo(otherCell.x, otherCell.y, o.color, false).startSplitting();
		}

		isShadowVisible = false;
		isVisible = false;
	}

	function getPrimaryColor(geloColor: GeloColor) {
		return prefsSettings.primaryColors[geloColor];
	}

	function renderShadow(g: Graphics, g4: Graphics4, alpha: Float) {
		if (!prefsSettings.showGroupShadow || !isShadowVisible)
			return;

		final shadowOpacity = prefsSettings.shadowOpacity;
		final quarterSize = Gelo.HALFSIZE / 2;
		final radius = prefsSettings.shadowWillTriggerChain
			&& willTriggerChain ? quarterSize + Math.cos(willTriggerChainT / 4) * quarterSize / 2 : quarterSize;

		g.pushOpacity(shadowOpacity);

		for (o in otherShadows) {
			g.color = getPrimaryColor(o.color);
			g.fillCircle(o.x, o.y, radius, 16);
		}

		g.popOpacity();

		if (prefsSettings.shadowHighlightOthers) {
			final background = prefsSettings.boardBackground;

			for (o in otherShadows) {
				g.color = background;
				g.fillCircle(o.x, o.y, radius - 8, 16);
			}
		}

		g.pushOpacity(shadowOpacity);

		g.color = getPrimaryColor(mainShadow.color);
		g.fillCircle(mainShadow.x, mainShadow.y, radius, 16);

		g.popOpacity();

		g.color = White;
	}

	function renderGelo(g: Graphics, g4: Graphics4, x: Float, y: Float, alpha: Float, gelo: Gelo) {
		gelo.render(g, g4, x, y, alpha);
	}

	public function update() {
		if (main == null)
			return;

		prevRotationAngle = rotationAngle;
		updateRotation();

		main.update();

		for (o in others) {
			o.update();
		}

		prevDisplayX = displayX;
		prevDisplayY = displayY;

		updateSmoothing();

		willTriggerChainT++;
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		renderShadow(g, g4, alpha);

		if (!isVisible)
			return;

		final fallChoppyness = rule.animations == TSU ? Gelo.HALFSIZE : 1;

		final prevChoppyY = Math.fround(prevDisplayY / fallChoppyness) * fallChoppyness;
		final choppyY = Math.fround(displayY / fallChoppyness) * fallChoppyness;

		final lerpDisplayX = lerp(prevDisplayX, displayX, alpha);
		final lerpDisplayY = lerp(prevChoppyY, choppyY, alpha);

		final prevCos = Math.cos(prevRotationAngle / 16 * Math.PI);
		final currentCos = Math.cos(rotationAngle / 16 * Math.PI);

		final prevSin = Math.sin(prevRotationAngle / 16 * Math.PI);
		final currentSin = Math.sin(rotationAngle / 16 * Math.PI);

		final lerpCos = lerp(prevCos, currentCos, alpha);
		final lerpSin = lerp(prevSin, currentSin, alpha);

		for (o in others) {
			renderGelo(g, g4, lerpDisplayX + lerpCos * Gelo.SIZE, lerpDisplayY + lerpSin * Gelo.SIZE, alpha, o);
		}

		renderGelo(g, g4, lerpDisplayX, lerpDisplayY, alpha, main);

		g.color = White;
	}
}

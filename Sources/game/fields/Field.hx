package game.fields;

import hxbit.Serializer;
import game.gelos.FieldGeloPoint;
import save_data.PrefsSettings;
import game.copying.CopyableMatrix;
import game.copying.ICopyFrom;
import utils.Utils;
import game.gelos.GarbageGelo;
import game.copying.CopyableRNG;
import game.gelos.GeloColor;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import utils.IntPoint;
import game.gelos.FieldGelo;
import game.gelos.Gelo;
import utils.Point;
import utils.Utils.negativeMod;
import haxe.ds.ReadOnlyArray;

using Safety;

@:structInit
@:build(game.Macros.buildOptionsClass(Field))
class FieldOptions {}

class Field implements ICopyFrom {
	static final ORIGINAL_GARBAGE_ACCELERATIONS = [0.5625, 0.59375, 0.5, 0.5625, 0.53125, 0.625];
	static final ORIGINAL_GARBAGE_COLUMNS = [0, 3, 2, 5, 1, 4];

	@inject final prefsSettings: PrefsSettings;

	@nullCopyFrom var markers: Null<CopyableMatrix<IFieldMarker>>;
	@nullCopyFrom var gelos: Null<CopyableMatrix<FieldGelo>>;

	@inject public var columns(default, null): Int;
	@inject public var playAreaRows(default, null): Int;
	@inject public var garbageRows(default, null): Int;
	@inject public var hiddenRows: Int;

	@copy public var outerRows(default, null): Int;
	@copy public var totalRows(default, null): Int;
	@copy public var centerColumnIndex(default, null): Int;

	@copy public var garbageAccelerations(default, null): ReadOnlyArray<Float>;
	@copy public var garbageColumns(default, null): ReadOnlyArray<Int>;

	public function copy(): Dynamic {
		return new Field({
			prefsSettings: prefsSettings,
			columns: columns,
			playAreaRows: playAreaRows,
			hiddenRows: hiddenRows,
			garbageRows: garbageRows
		}).copyFrom(this);
	}

	public function new(opts: FieldOptions) {
		Macros.initFromOpts();

		outerRows = 0;
		totalRows = 0;
		centerColumnIndex = 0;

		garbageAccelerations = [];
		garbageColumns = [];

		createData();
	}

	inline function rawSet(x: Int, y: Int, gelo: FieldGelo) {
		if (gelos != null) {
			gelos.data[y][x] = gelo;
		}
	}

	inline function rawSetMarker(x: Int, y: Int, marker: IFieldMarker) {
		if (markers != null) {
			markers.data[y][x] = marker;
		}
	}

	public function createData() {
		outerRows = hiddenRows + garbageRows;
		totalRows = playAreaRows + outerRows;

		centerColumnIndex = Std.int(columns / 2) - 1;

		gelos = new CopyableMatrix(totalRows);
		markers = new CopyableMatrix(totalRows);

		for (y in 0...totalRows) {
			gelos.sure().data[y] = [];
			markers.data[y] = [];

			for (x in 0...columns) {
				rawSetMarker(x, y, NullFieldMarker.instance);
			}
		}

		final garbageVels = [];

		for (x in 0...columns) {
			garbageVels.push(ORIGINAL_GARBAGE_ACCELERATIONS[x % 6]);
		}

		garbageAccelerations = garbageVels;

		if (columns == 6) {
			garbageColumns = ORIGINAL_GARBAGE_COLUMNS.copy();
		} else {
			final pool = [for (x in 0...columns) x];
			final garbageCols = [];
			final rng = new CopyableRNG(columns);

			while (pool.length > 0) {
				final item = pool[rng.data.GetUpTo(pool.length - 1)];

				garbageCols.push(item);
				pool.remove(item);
			}

			garbageColumns = garbageCols;
		}
	}

	public function get(x: Int, y: Int): Null<FieldGelo> {
		if (gelos == null) {
			return null;
		}

		return gelos.data[y][x];
	}

	public function getMarker(x: Int, y: Int): Null<IFieldMarker> {
		if (markers == null) {
			return null;
		}

		return markers.data[y][x];
	}

	public inline function getAtPoint(p: IntPoint) {
		return get(p.x, p.y);
	}

	public function set(x: Int, y: Int, gelo: FieldGelo) {
		final screenCoords = cellToScreen(x, y);

		gelo.x = screenCoords.x;
		gelo.y = screenCoords.y;

		rawSet(x, y, gelo);
	}

	public function setMarker(x: Int, y: Int, marker: IFieldMarker) {
		rawSetMarker(x, y, getMarker(x, y).sure().onSet(marker.copy()));
	}

	public function newGelo(x: Int, y: Int, color: GeloColor, lockInGarbage: Bool) {
		final screenCoords = cellToScreen(x, y);

		final gelo = FieldGelo.create({
			prefsSettings: prefsSettings,
			color: color,
			x: screenCoords.x,
			y: screenCoords.y
		});

		// Do not create Gelos in the garbage creation area
		if (!lockInGarbage && y < garbageRows) {
			return gelo;
		}

		rawSet(x, y, gelo);

		return gelo;
	}

	public function newGarbage(x: Int, y: Int, color: GeloColor) {
		final screenCoords = cellToScreen(x, y);

		final garbo = GarbageGelo.create({
			prefsSettings: prefsSettings,
			color: color,
			x: screenCoords.x,
			y: screenCoords.y
		});

		// Do not create Garbage in the play area
		if (y >= garbageRows) {
			return garbo;
		}

		rawSet(x, y, garbo);

		return garbo;
	}

	public function clear(x: Int, y: Int) {
		if (gelos == null) {
			return;
		}

		gelos.data[y][x] = null;
	}

	public function clearMarker(x: Int, y: Int) {
		rawSetMarker(x, y, NullFieldMarker.instance);
	}

	public function clearAll() {
		forEach((_, x, y) -> {
			clear(x, y);
		});
	}

	inline public function isEmpty(x: Int, y: Int) {
		return get(x, y) == null;
	}

	inline public function isMarkerEmpty(x: Int, y: Int) {
		return getMarker(x, y) == NullFieldMarker.instance;
	}

	inline public function isEmptyAtPoint(p: IntPoint) {
		return isEmpty(p.x, p.y);
	}

	inline public function cannotPlace(x: Int, y: Int) {
		return 0 > x || x > columns - 1 || 0 > y || y > totalRows - 1 || !isEmpty(x, y);
	}

	public function cannotShift(x: Int, y: Int) {
		return 0 > x || x > columns - 1 || !isEmpty(x, y);
	}

	public function customForEach(startY: Int, endY: Int, callback: (FieldGelo, Int, Int) -> Void) {
		final diff = endY - startY;
		final increment = Std.int(diff / Math.abs(diff));

		var y = startY;

		do {
			for (x in 0...columns) {
				final gelo = get(x, y);
				if (gelo == null)
					continue;

				callback(gelo, x, y);
			}

			y += increment;
		} while (y != endY);
	}

	inline public function forEach(callback: (FieldGelo, Int, Int) -> Void) {
		customForEach(0, totalRows, callback);
	}

	public function checkAround(x: Int, y: Int, callback: (FieldGelo, Int, Int, Int) -> Void) {
		for (i in 0...4) {
			final p = Utils.AROUND[i];
			final cellX = x + p.x;
			final cellY = y + p.y;

			if (cellX < 0)
				continue;
			if (cellX > columns - 1)
				continue;
			if (cellY < outerRows)
				continue;
			if (cellY > totalRows - 1)
				continue;
			if (isEmpty(cellX, cellY))
				continue;

			final gelo = get(cellX, cellY);

			if (gelo == null) {
				continue;
			}

			callback(gelo, cellX, cellY, i);
		}
	}

	public function checkConnections(?onConnected: Array<FieldGeloPoint>->Void, ?onCheck: (FieldGelo, Int) -> Void, ?onCurrent: FieldGelo->Void) {
		if (onConnected == null)
			onConnected = (_) -> {};
		if (onCheck == null)
			onCheck = (_, _) -> {};
		if (onCurrent == null)
			onCurrent = (_) -> {};

		final checkedCells = [for (_ in 0...totalRows) [for (_ in 0...columns) false]];

		customForEach(outerRows, totalRows, (gelo, x, y) -> {
			if (gelo == null)
				return;

			final color = gelo.color;

			if (color.isGarbage())
				return;

			final connected: Array<FieldGeloPoint> = [{color: color, x: x, y: y}];
			var checkedCount = 1;

			checkedCells[y][x] = true;

			while (checkedCount <= connected.length) {
				final current = connected[checkedCount - 1];

				checkAround(current.x, current.y, (checkedGelo, checkedX, checkedY, i) -> {
					if (color == checkedGelo.color) {
						onCheck(checkedGelo, i);

						if (!checkedCells[checkedY][checkedX]) {
							connected.push({color: color, x: checkedX, y: checkedY});
							checkedCells[checkedY][checkedX] = true;
						}
					}
				});

				final gelo = getAtPoint(current);

				if (gelo != null) {
					onCurrent(gelo);
				}

				checkedCount++;
			}

			onConnected(connected);
		});
	}

	public function setSpriteVariations() {
		var bitField = 0;

		function onCheck(checkedGelo: FieldGelo, i: Int) {
			if (checkedGelo.state != IDLE)
				return;
			bitField += 1 << i;
		}

		function afterCheck(gelo: FieldGelo) {
			if (gelo.state == IDLE)
				gelo.changeSpriteVariation(bitField);
			bitField = 0;
		}

		checkConnections(null, onCheck, afterCheck);
	}

	public function drop() {
		var allLocked: Bool;

		do {
			allLocked = true;

			customForEach(totalRows - 1, 0, (gelo, x, y) -> {
				final nextY = y + 1;

				if (nextY < totalRows && isEmpty(x, nextY)) {
					allLocked = false;

					clear(x, y);
					set(x, nextY, gelo);
				} else {
					gelo.stopFalling();
				}
			});
		} while (!allLocked);
	}

	public function updateFall(startY: Int, endY: Int) {
		var allDown = true;

		customForEach(startY, endY, (gelo, origX, origY) -> {
			if (gelo.state == IDLE)
				return;

			if (gelo.state == FALLING) {
				final x = gelo.x;
				final y = gelo.y;

				final nextY = y + gelo.velocity;

				final cellCoords = screenToCell(x, nextY + Gelo.HALFSIZE);

				if (cellCoords.y < totalRows && (isEmptyAtPoint(cellCoords) || getAtPoint(cellCoords).sure().state == FALLING)) {
					gelo.distanceCounter += gelo.velocity;
					gelo.y = nextY;
					gelo.changeSpriteVariation(NONE);
				} else {
					// Round position
					gelo.x = Math.min(gelo.x - (negativeMod(gelo.x, Gelo.SIZE) - Gelo.HALFSIZE), columns * Gelo.SIZE);
					gelo.y = Math.min(gelo.y - (negativeMod(gelo.y, Gelo.SIZE) - Gelo.HALFSIZE), totalRows * Gelo.SIZE);

					final distance = gelo.distanceCounter;

					if (distance < 1) {
						gelo.stopBouncing();
					} else if (distance < Gelo.HALFSIZE) {
						gelo.startBouncing(TSU_SHORT);
					} else {
						gelo.startBouncing(TSU_LONG);
					}

					clear(origX, origY);

					final newCells = screenToCell(gelo.x, gelo.y);

					set(newCells.x, newCells.y, gelo);
				}

				gelo.velocity = Math.min(gelo.velocity + gelo.accel, gelo.velocityLimit);
			}

			allDown = false;
		});

		return allDown;
	}

	public function cellToScreen(cellX: Int, cellY: Int): Point {
		final screenX = (cellX + 1) * Gelo.SIZE - Gelo.HALFSIZE;
		final screenY = (cellY + 1) * Gelo.SIZE - outerRows * Gelo.SIZE - Gelo.HALFSIZE;

		return {x: screenX, y: screenY};
	}

	public function screenToCell(screenX: Float, screenY: Float): IntPoint {
		final fieldX = Math.round((screenX + Gelo.HALFSIZE) / Gelo.SIZE) - 1;
		final fieldY = Math.round((screenY + outerRows * Gelo.SIZE + Gelo.HALFSIZE) / Gelo.SIZE) - 1;

		return {x: fieldX, y: fieldY};
	}

	public function addDesyncInfo(ctx: Serializer) {
		for (y in 0...totalRows) {
			for (x in 0...columns) {
				final gelo = get(x, y);

				if (gelo == null) {
					ctx.addByte(0);

					continue;
				}

				final g = gelo.sure();

				if (g.state != IDLE) {
					ctx.addByte(0);

					continue;
				}

				ctx.addInt(g.color);
			}
		}
	}

	public function update() {
		forEach((gelo, _, _) -> {
			gelo.update();
		});
	}

	public function render(g: Graphics, g4: Graphics4, alpha: Float) {
		for (y in 0...totalRows) {
			for (x in 0...columns) {
				final marker = getMarker(x, y);

				if (marker == null) {
					continue;
				}

				final screenCoords = cellToScreen(x, y);
				final screenX = screenCoords.x - Gelo.HALFSIZE;
				final screenY = screenCoords.y - Gelo.HALFSIZE;

				marker.sure().render(g, screenX, screenY);
			}
		}

		forEach((gelo, x, y) -> {
			gelo.renderAtOwnPosition(g, g4, alpha);
		});
	}
}

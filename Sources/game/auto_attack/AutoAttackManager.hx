package game.auto_attack;

import utils.ValueBox;
import game.copying.ConstantCopyableArray;
import game.copying.ICopyFrom;
import kha.graphics2.Graphics;
import game.gelos.Gelo;
import game.particles.GeloPopParticle;
import game.particles.ParticleManager;
import save_data.PrefsSettings;
import game.geometries.BoardGeometries;
import game.ChainCounter;
import utils.Point;
import game.simulation.ILinkInfoBuilder;
import save_data.TrainingSettings;
import game.copying.CopyableRNG;
import game.garbage.IGarbageManager;
import game.simulation.LinkInfo;
import game.gelos.GeloColor;

private enum abstract InnerState(Int) {
	final WAITING;
	final SENDING;
}

@:structInit
@:build(game.Macros.buildOptionsClass(AutoAttackManager))
class AutoAttackManagerOptions {}

class AutoAttackManager implements ICopyFrom {
	static inline final EFFECT_Y = 800;

	@inject final popCount: ValueBox<Int>;
	@inject final rng: CopyableRNG;
	@inject final geometries: BoardGeometries;
	@inject final trainingSettings: TrainingSettings;
	@inject final prefsSettings: PrefsSettings;
	@inject final linkBuilder: ILinkInfoBuilder;
	@inject final garbageManager: IGarbageManager;
	@inject final chainCounter: ChainCounter;
	@inject final particleManager: ParticleManager;

	final links: ConstantCopyableArray<LinkInfo>;

	@copy var accumGarbage: Int;
	@copy var linkIndex: Int;

	@copy public final linkData: ConstantCopyableArray<AutoAttackLinkData>;

	@copy public var timer(default, null): Int;
	@copy public var chain(default, null): Int;
	@copy public var state(default, null): InnerState;

	@copy public var isPaused: Bool;
	@copy public var type: AutoAttackType;

	public function new(opts: AutoAttackManagerOptions) {
		game.Macros.initFromOpts();

		links = new ConstantCopyableArray([]);

		linkData = new ConstantCopyableArray([]);

		isPaused = true;
		type = RANDOM;
	}

	function constructRandomLinks() {
		links.data.resize(0);

		accumGarbage = 0;
		chain = 0;

		var remainder = 0.0;

		for (_ in 0...rng.data.GetIn(trainingSettings.minAttackChain, trainingSettings.maxAttackChain)) {
			final clearsByColor = [COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0];

			final colorCount = rng.data.GetIn(trainingSettings.minAttackColors, trainingSettings.maxAttackColors);

			for (i in 0...colorCount) {
				clearsByColor[i] = popCount.v + rng.data.GetIn(trainingSettings.minAttackGroupDiff, trainingSettings.maxAttackGroupDiff);
			}

			final link = linkBuilder.build({
				chain: ++chain,
				clearsByColor: clearsByColor,
				totalGarbage: accumGarbage,
				garbageRemainder: remainder,
				dropBonus: 0,
				sendsAllClearBonus: false
			});

			remainder = link.garbageRemainder;
			accumGarbage = link.accumulatedGarbage;

			links.data.push(link);
		}
	}

	function onWaitingEnd() {
		garbageManager.clear();

		linkIndex = 0;

		if (type == RANDOM)
			constructRandomLinks();

		if (links.data.length > 0)
			state = SENDING;
		else
			reset();
	}

	function onSendingEnd() {
		final link = links.data[linkIndex];

		linkIndex++;

		garbageManager.sendGarbage(link.garbage, [{x: 0, y: EFFECT_Y, color: COLOR2}]);

		final coords: Point = {x: 112, y: EFFECT_Y};

		chainCounter.startAnimation(link.chain, coords, link.isPowerful);

		final absCoords = geometries.absolutePosition.add(coords);
		final color = prefsSettings.primaryColors[COLOR2];

		for (i in 0...48) {
			particleManager.add(FRONT, GeloPopParticle.create({
				x: absCoords.x + Gelo.HALFSIZE * rng.data.GetFloatIn(-1, 1),
				y: absCoords.y + Gelo.HALFSIZE * rng.data.GetFloatIn(-1, 1),
				dx: ((i % 2 == 0) ? -8 : 8) * rng.data.GetFloatIn(0.5, 1.5),
				dy: -10 * rng.data.GetFloatIn(0.5, 1.5),
				dyIncrement: 0.75 * rng.data.GetFloatIn(0.5, 1.5),
				maxT: Std.int((30 + i * 6) * rng.data.GetFloatIn(0.5, 1.5)),
				color: color
			}));
		}

		if (linkIndex == links.data.length) {
			garbageManager.confirmGarbage(accumGarbage);

			reset();
		} else {
			timer = 80;
		}
	}

	public function reset() {
		timer = rng.data.GetIn(trainingSettings.minAttackTime, trainingSettings.maxAttackTime) * 60;
		state = WAITING;
	}

	public function constructLinks() {
		links.data.resize(0);

		accumGarbage = 0;
		chain = 0;

		var remainder = 0.0;

		for (d in linkData.data) {
			final link = linkBuilder.build({
				chain: ++chain,
				clearsByColor: d.clearsByColor,
				totalGarbage: accumGarbage,
				garbageRemainder: remainder,
				sendsAllClearBonus: d.sendsAllClearBonus,
				dropBonus: 0
			});

			remainder = link.garbageRemainder;
			accumGarbage = link.accumulatedGarbage;

			links.data.push(link);
		}
	}

	public function update() {
		if (isPaused)
			return;

		if (timer == 0) {
			switch (state) {
				case WAITING:
					onWaitingEnd();
				case SENDING:
					onSendingEnd();
			}

			return;
		}

		timer--;

		chainCounter.update();
	}

	public function render(g: Graphics, alpha: Float) {
		chainCounter.render(g, alpha);
	}
}

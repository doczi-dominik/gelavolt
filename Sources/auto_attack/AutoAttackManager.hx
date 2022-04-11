package auto_attack;

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
import kha.math.Random;
import game.rules.Rule;
import game.garbage.IGarbageManager;
import game.simulation.LinkInfo;
import game.gelos.GeloColor;

private enum abstract InnerState(Int) {
	final WAITING;
	final SENDING;
}

class AutoAttackManager {
	static inline final EFFECT_Y = 800;

	final rule: Rule;
	final rng: Random;
	final geometries: BoardGeometries;
	final trainingSettings: TrainingSettings;
	final prefsSettings: PrefsSettings;
	final linkBuilder: ILinkInfoBuilder;
	final garbageManager: IGarbageManager;
	final chainCounter: ChainCounter;
	final particleManager: ParticleManager;

	final links: Array<LinkInfo>;

	var accumGarbage: Int;
	var linkIndex: Int;

	public final linkData: Array<AutoAttackLinkData>;

	public var timer(default, null): Int;
	public var chain(default, null): Int;
	public var state(default, null): InnerState;

	public var isPaused: Bool;
	public var type: AutoAttackType;

	public function new(opts: AutoAttackManagerOptions) {
		rule = opts.rule;
		rng = opts.rng;
		geometries = opts.geometries;
		trainingSettings = opts.trainingSettings;
		prefsSettings = opts.prefsSettings;
		linkBuilder = opts.linkBuilder;
		garbageManager = opts.garbageManager;
		chainCounter = opts.chainCounter;
		particleManager = opts.particleManager;

		links = [];

		linkData = [];

		isPaused = true;
		type = RANDOM;
	}

	function constructRandomLinks() {
		links.resize(0);

		accumGarbage = 0;
		chain = 0;

		var remainder = 0.0;

		for (_ in 0...rng.GetIn(trainingSettings.minAttackChain, trainingSettings.maxAttackChain)) {
			final clearsByColor = [COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0];

			final colorCount = rng.GetIn(trainingSettings.minAttackColors, trainingSettings.maxAttackColors);

			for (i in 0...colorCount) {
				clearsByColor[i] = rule.popCount + rng.GetIn(trainingSettings.minAttackGroupDiff, trainingSettings.maxAttackGroupDiff);
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

			links.push(link);
		}
	}

	function onWaitingEnd() {
		garbageManager.clear();

		linkIndex = 0;

		if (type == RANDOM)
			constructRandomLinks();

		if (links.length > 0)
			state = SENDING;
		else
			reset();
	}

	function onSendingEnd() {
		final link = links[linkIndex];

		linkIndex++;

		garbageManager.sendGarbage(link.garbage, [{x: 0, y: EFFECT_Y, color: COLOR2}]);

		final coords: Point = {x: 112, y: EFFECT_Y};

		chainCounter.startAnimation(link.chain, coords, link.isPowerful);

		final absCoords = geometries.absolutePosition.add(coords);
		final color = prefsSettings.primaryColors[COLOR2];

		for (i in 0...48) {
			particleManager.add(FRONT, GeloPopParticle.create({
				x: absCoords.x + Gelo.HALFSIZE * rng.GetFloatIn(-1, 1),
				y: absCoords.y + Gelo.HALFSIZE * rng.GetFloatIn(-1, 1),
				dx: ((i % 2 == 0) ? -8 : 8) * rng.GetFloatIn(0.5, 1.5),
				dy: -10 * rng.GetFloatIn(0.5, 1.5),
				dyIncrement: 0.75 * rng.GetFloatIn(0.5, 1.5),
				maxT: Std.int((30 + i * 6) * rng.GetFloatIn(0.5, 1.5)),
				color: color
			}));
		}

		if (linkIndex == links.length) {
			garbageManager.confirmGarbage(accumGarbage);

			reset();
		} else {
			timer = 80;
		}
	}

	public function reset() {
		timer = rng.GetIn(trainingSettings.minAttackTime, trainingSettings.maxAttackTime) * 60;
		state = WAITING;
	}

	public function constructLinks() {
		links.resize(0);

		accumGarbage = 0;
		chain = 0;

		var remainder = 0.0;

		for (d in linkData) {
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

			links.push(link);
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

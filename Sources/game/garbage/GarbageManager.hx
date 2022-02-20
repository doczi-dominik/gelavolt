package game.garbage;

import utils.Utils;
import game.mediators.GarbageTargetMediator;
import save_data.PrefsSave;
import game.garbage.trays.GarbageTray;
import game.screens.GameScreen;
import game.gelos.Gelo;
import game.geometries.BoardGeometries;
import utils.Point;
import game.particles.GarbageBulletParticle;
import game.particles.IParticleManager;
import kha.graphics2.Graphics;
import game.gelos.GeloPoint;
import game.rules.Rule;

class GarbageManager implements IGarbageManager {
	final rule: Rule;
	final prefsSave: PrefsSave;
	final particleManager: IParticleManager;
	final geometries: BoardGeometries;
	final tray: GarbageTray;
	final target: GarbageTargetMediator;

	var currentGarbage: Int;
	var confirmedGarbage: Int;
	var graceT: Int;

	public var canReceiveGarbage: Bool;
	public var droppableGarbage(get, never): Int;

	public function new(opts: GarbageManagerOptions) {
		rule = opts.rule;
		prefsSave = opts.prefsSave;
		particleManager = opts.particleManager;
		geometries = opts.geometries;
		tray = opts.tray;
		target = opts.target;

		currentGarbage = 0;
		confirmedGarbage = 0;
		graceT = 0;

		canReceiveGarbage = true;

		startAnimation();
	}

	function get_droppableGarbage() {
		if (graceT > 0)
			return 0;

		return Std.int(Math.min(confirmedGarbage, rule.garbageDropLimit));
	}

	final function updateNothing() {}

	function reduceGarbage(amount: Int) {
		currentGarbage = Std.int(Math.max(0, currentGarbage - amount));
		confirmedGarbage = Utils.intClamp(0, confirmedGarbage, currentGarbage);
	}

	// Note: GeloPoint are screen coordinates not field
	// TODO: Make FieldGeloPoint and ScreenGeloPoint that extend IntPoint/Point
	function sendAttackBullet(beginners: Array<GeloPoint>) {
		final absPos = geometries.absolutePosition;

		final control: Point = switch (geometries.orientation) {
			case LEFT: {x: 0, y: 0};
			case RIGHT: {x: BoardGeometries.WIDTH, y: 0};
		}

		for (b in beginners) {
			final targetGeometries = target.geometries;
			final trayCenter = targetGeometries.garbageTray.add({x: BoardGeometries.CENTER.x, y: Gelo.HALFSIZE});

			particleManager.add(FRONT, GarbageBulletParticle.create({
				particleManager: particleManager,
				layer: FRONT,
				begin: absPos.add({x: b.x, y: b.y}),
				beginScale: 1, // TODO
				control: absPos.add(control),
				target: targetGeometries.absolutePosition.add(trayCenter),
				targetScale: 1,
				duration: 30,
				color: prefsSave.primaryColors[b.color],
				onFinish: target.startAnimation
			}));
		}
	}

	function sendOffsetBullet(beginners: Array<GeloPoint>) {
		final absPos = geometries.absolutePosition;
		final scale = geometries.scale;

		final absCenter = absPos.add(BoardGeometries.CENTER);
		final trayCenter = geometries.garbageTray.add({x: BoardGeometries.CENTER.x, y: Gelo.HALFSIZE});
		final absTarget = absPos.add(trayCenter);

		for (b in beginners) {
			final absBegin = absPos.add({x: b.x, y: b.y});

			particleManager.add(FRONT, GarbageBulletParticle.create({
				particleManager: particleManager,
				layer: FRONT,
				begin: absBegin,
				beginScale: scale,
				control: absCenter,
				target: absTarget,
				targetScale: scale,
				duration: 30,
				color: prefsSave.primaryColors[b.color],
				onFinish: startAnimation
			}));
		}
	}

	function sendCounterBullet(beginners: Array<GeloPoint>) {
		final absPos = geometries.absolutePosition;
		final scale = geometries.scale;

		final absCenter = absPos.add(BoardGeometries.CENTER);
		final trayCenter = geometries.garbageTray.add({x: BoardGeometries.CENTER.x, y: Gelo.HALFSIZE});
		final absTrayCenter = absPos.add(trayCenter);

		final attackControl: Point = {
			x: GameScreen.PLAY_AREA_DESIGN_WIDTH / 2,
			y: 0
		};

		final targetGeometries = target.geometries;
		final targetTrayCenter = targetGeometries.garbageTray.add({x: BoardGeometries.CENTER.x, y: 0});
		final absTargetTrayCenter = targetGeometries.absolutePosition.add(targetTrayCenter);

		for (b in beginners) {
			final color = prefsSave.primaryColors[b.color];
			final absBegin = absPos.add({x: b.x, y: b.y});

			particleManager.add(FRONT, GarbageBulletParticle.create({
				particleManager: particleManager,
				layer: FRONT,
				begin: absBegin,
				beginScale: scale,
				control: absCenter,
				target: absTrayCenter,
				targetScale: scale,
				duration: 30,
				color: prefsSave.primaryColors[b.color],
				onFinish: () -> {
					startAnimation();

					particleManager.add(FRONT, GarbageBulletParticle.create({
						particleManager: particleManager,
						layer: FRONT,
						begin: absTrayCenter,
						beginScale: scale,
						control: attackControl,
						target: absTargetTrayCenter,
						targetScale: targetGeometries.scale,
						duration: 20,
						color: color,
						onFinish: target.startAnimation
					}));
				}
			}));
		}
	}

	function receiveGarbage(amount: Int) {
		currentGarbage += amount;
	}

	function setConfirmedGarbage(amount: Int) {
		confirmedGarbage += Std.int(Math.min(amount, currentGarbage));
		graceT = rule.garbageConfirmGracePeriod;
	}

	function startAnimation() {
		tray.startAnimation(currentGarbage);
	}

	public function sendGarbage(amount: Int, beginners: Array<GeloPoint>) {
		if (amount == 0)
			return;

		final diff = amount - currentGarbage;

		if (currentGarbage == 0) {
			// Attacking
			target.receiveGarbage(amount);

			sendAttackBullet(beginners);
		} else if (diff >= 0) {
			// Countering
			reduceGarbage(currentGarbage);

			if (diff > 0) {
				target.receiveGarbage(diff);

				sendCounterBullet(beginners);
			}
		} else if (diff < 0) {
			// Offsetting
			reduceGarbage(amount);

			sendOffsetBullet(beginners);
		}
	}

	public function dropGarbage(amount: Int) {
		reduceGarbage(amount);
		startAnimation();
	}

	public function confirmGarbage(amount: Int) {
		target.setConfirmedGarbage(amount);
	}

	public function clear() {
		reduceGarbage(currentGarbage);
		startAnimation();
	}

	public function update() {
		tray.update();

		if (graceT > 0)
			graceT--;
	}

	public function render(g: Graphics, x: Float, y: Float, alpha: Float) {
		tray.render(g, x, y, alpha);
	}
}

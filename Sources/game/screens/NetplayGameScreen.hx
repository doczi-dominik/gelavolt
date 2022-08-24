package game.screens;

import hxbit.Serializer;
import haxe.crypto.Crc32;
import game.mediators.FrameCounter;
import haxe.ds.Vector;
import game.gamestatebuilders.INetplayGameStateBuilder;
import kha.graphics4.Graphics as Graphics4;
import kha.graphics2.Graphics;
import game.net.SessionManager;

private class ElapsedFrame {
	public final builder: INetplayGameStateBuilder;

	public var frame: Int;

	public function new(builder: INetplayGameStateBuilder) {
		this.builder = builder;

		frame = 0;
	}
}

@:structInit
@:build(game.Macros.buildOptionsClass(NetplayGameScreen))
class NetplayGameScreenOptions {}

class NetplayGameScreen extends GameScreenBase {
	static inline final ROLLBACK_BUFFER_SIZE = 15;

	@inject final session: SessionManager;
	@inject final frameCounter: FrameCounter;
	@inject final gameStateBuilder: INetplayGameStateBuilder;

	final elapsedFrames: Vector<ElapsedFrame>;
	final serializer: Serializer;

	var sleepCounter: Int;
	var serializeCounter: Int;

	public function new(opts: NetplayGameScreenOptions) {
		super();

		Macros.initFromOpts();

		gameStateBuilder.controlHintContainer = controlHintContainer;

		gameStateBuilder.pauseMediator = {
			pause: pause,
			resume: resume
		};

		gameStateBuilder.rollbackMediator = {
			confirmFrame: confirmFrame,
			rollback: rollback
		};

		gameStateBuilder.build();

		gameState = gameStateBuilder.gameState;
		pauseMenu = gameStateBuilder.pauseMenu;

		elapsedFrames = new Vector(ROLLBACK_BUFFER_SIZE);

		for (i in 0...elapsedFrames.length) {
			elapsedFrames[i] = new ElapsedFrame(gameStateBuilder.createBackupBuilder());
			elapsedFrames[i].builder.build();
		}

		serializer = new Serializer();

		sleepCounter = 0;
		serializeCounter = 0;
	}

	override function updatePaused() {
		pauseMenu.update();
		updateGameState();
	}

	override function updateRunning() {
		background.update();
		updateGameState();
	}

	function updateGameState() {
		if (sleepCounter > 0) {
			sleepCounter--;
			return;
		}

		sleepCounter = session.update();

		if (session.state == RUNNING) {
			gameState.update();

			confirmFrame();

			if (++serializeCounter > 120) {
				final ser = serializer.serialize(gameState);
				final checksum = '${Crc32.make(ser)}';

				session.sendDesyncChecksum(checksum);
				serializeCounter = 0;
			}
		}
	}

	inline function confirmFrame() {
		final ringBufferIndex = frameCounter.value % ROLLBACK_BUFFER_SIZE;

		elapsedFrames[ringBufferIndex].frame = frameCounter.value;
		elapsedFrames[ringBufferIndex].builder.copyFrom(gameStateBuilder);
	}

	function rollback(from: Int) {
		var i = ROLLBACK_BUFFER_SIZE;

		final target = frameCounter.value;

		while (--i > 0) {
			if (elapsedFrames[i].frame == from) {
				gameStateBuilder.copyFrom(elapsedFrames[i].builder);
				break;
			}
		}

		while (frameCounter.value <= target) {
			gameState.update();
			confirmFrame();
		}
	}

	override function dispose() {
		session.dispose();
	}

	override function render(g: Graphics, g4: Graphics4, alpha: Float) {
		super.render(g, g4, alpha);

		g.font = font;
		g.fontSize = fontSize;

		final status = 'L: ${session.averageLocalAdvantage} -- R: ${session.averageRemoteAdvantage} -- RTT: ${session.averageRTT}';

		g.drawString(switch (session.state) {
			case WAITING: "Waiting For Peer...";
			case SYNCING: 'Synchronizing -- C: ${session.successfulSleepChecks}/5 -- $status';
			case BEGINNING: "Synchronized! Game will begin soon...";
			case RUNNING: 'S: $sleepCounter -- $status';
		}, 0, 0);
	}
}

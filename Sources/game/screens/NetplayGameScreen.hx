package game.screens;

import hxbit.Serializer;
import haxe.crypto.Crc32;
import game.mediators.FrameCounter;
import game.gamestatebuilders.INetplayGameStateBuilder;
import kha.graphics4.Graphics as Graphics4;
import kha.graphics2.Graphics;
import game.net.SessionManager;

@:structInit
@:build(game.Macros.buildOptionsClass(NetplayGameScreen))
class NetplayGameScreenOptions {}

class NetplayGameScreen extends GameScreenBase {
	@inject final session: SessionManager;
	@inject final frameCounter: FrameCounter;
	@inject final gameStateBuilder: INetplayGameStateBuilder;

	final serializer: Serializer;

	var lastConfirmedFrame: INetplayGameStateBuilder;

	public function new(opts: NetplayGameScreenOptions) {
		super();

		Macros.initFromOpts();

		session.onCalculateChecksum = onCalculateChecksum;
		session.onConfirmFrame = confirmFrame;

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

		serializer = new Serializer();

		lastConfirmedFrame = gameStateBuilder.createBackupBuilder();
		lastConfirmedFrame.build();
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
		session.update();

		if (session.sleepFrames > 0) {
			return;
		}

		if (session.state == RUNNING) {
			gameState.update();
		}
	}

	function onCalculateChecksum() {
		serializer.begin();
		gameState.addDesyncInfo(serializer);

		final crc = Crc32.make(serializer.end());

		return Std.string(crc).substr(0, 8);
	}

	function confirmFrame() {
		lastConfirmedFrame.copyFrom(gameStateBuilder);
	}

	function rollback(resimulate: Int) {
		gameStateBuilder.copyFrom(lastConfirmedFrame);

		while (--resimulate >= 0) {
			gameState.update();
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
			case RUNNING: 'S: ${session.sleepFrames} -- $status';
		}, 0, 0);
	}
}

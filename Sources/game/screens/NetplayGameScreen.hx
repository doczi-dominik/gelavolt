package game.screens;

import haxe.io.Bytes;
import hxbit.Serializer;
import haxe.crypto.Crc32;
import game.mediators.FrameCounter;
import haxe.ds.Vector;
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

	var sleepCounter: Int;
	var lastConfirmedFrame: INetplayGameStateBuilder;

	public function new(opts: NetplayGameScreenOptions) {
		super();

		Macros.initFromOpts();

		session.onChecksumRequest = onChecksumRequest;
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

		sleepCounter = 0;
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
		if (sleepCounter > 0) {
			sleepCounter--;
			return;
		}

		sleepCounter = session.update();

		if (session.state == RUNNING) {
			gameState.update();
		}
	}

	function onChecksumRequest() {
		serializer.begin();
		gameState.addDesyncInfo(serializer);

		return Std.string(Crc32.make(serializer.end()));
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
			case RUNNING: 'S: $sleepCounter -- $status';
		}, 0, 0);
	}
}

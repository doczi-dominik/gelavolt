package game.screens;

import input.AnyInputDevice;
import game.mediators.TransformationMediator;
import game.gamemodes.IGameMode;
import game.gamemodes.EndlessGameMode;
import game.gamemodes.TrainingGameMode;
import game.gamestatebuilders.EndlessGameStateBuilder;
import kha.System;
import kha.math.Random;
import game.backgrounds.NestBackground;
import game.states.GameState;
import game.gamestatebuilders.TrainingGameStateBuilder;
import kha.graphics2.Graphics;
import Screen.IScreen;

class GameScreen implements IScreen {
	final background: NestBackground;
	final transformMediator: TransformationMediator;
	final gameState: GameState;

	public function new(gameMode: IGameMode) {
		background = new NestBackground(new Random(Std.int(System.time * 1000000)));
		transformMediator = new TransformationMediator();

		gameState = setGameState(gameMode);

		ScaleManager.addOnResizeCallback(transformMediator.onResize);
	}

	function setGameState(gameMode: IGameMode) {
		return switch (gameMode.gameMode) {
			case TRAINING:
				new TrainingGameStateBuilder({
					gameMode: cast(gameMode, TrainingGameMode),
					transformMediator: transformMediator
				}).build();
			case ENDLESS:
				new EndlessGameStateBuilder({
					gameMode: cast(gameMode, EndlessGameMode),
					transformMediator: transformMediator,
					inputDevice: AnyInputDevice.instance
				}).build();
		}
	}

	public function update() {
		background.update();
		gameState.update();
	}

	public function render(g: Graphics, g4: kha.graphics4.Graphics, alpha: Float) {
		background.render(g, alpha);

		transformMediator.pushTransformation(g);

		gameState.renderTransformed(g, g4, alpha);

		g.popTransformation();

		gameState.render(g, g4, alpha);
	}
}

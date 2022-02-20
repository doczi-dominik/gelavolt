package game.actionbuffers;

import game.actions.GameActions;
import input.IInputDeviceManager;
import game.screens.GameScreen;

class LocalActionBuffer implements IActionBuffer {
	final gameScreen: GameScreen;
	final inputManager: IInputDeviceManager;
	final actions: Array<ActionSnapshot> = [];

	var currentAction: ActionSnapshot;

	public var latestAction(default, null): ActionSnapshot;

	public function new(opts: LocalActionBufferOptions) {
		gameScreen = opts.gameScreen;
		inputManager = opts.inputManager;

		currentAction = new ActionSnapshot();

		latestAction = new ActionSnapshot();
	}

	public function update() {
		currentAction.setFrame(gameScreen.currentFrame)
			.setShiftLeft(inputManager.getAction(SHIFT_LEFT))
			.setShiftRight(inputManager.getAction(SHIFT_RIGHT))
			.setRotateLeft(inputManager.getAction(ROTATE_LEFT))
			.setRotateRight(inputManager.getAction(ROTATE_RIGHT))
			.setSoftDrop(inputManager.getAction(SOFT_DROP))
			.setHardDrop(inputManager.getAction(HARD_DROP));

		if (latestAction.isNotEqual(currentAction)) {
			actions.push(currentAction);

			latestAction = currentAction;
			currentAction = new ActionSnapshot();
		}
	}
}

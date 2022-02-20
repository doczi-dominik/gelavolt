package game.actions;

import game.actions.Action;

enum abstract MenuActions(Action) to String {
	final PAUSE = "Pause";
	final LEFT = "Left";
	final RIGHT = "Right";
	final DOWN = "Down";
	final UP = "Up";
	final BACK = "Back";
	final CONFIRM = "Confirm";
}

package game.actions;

import game.actions.Action;

enum abstract GameActions(Action) to String {
	final SHIFT_LEFT = "Shift Group Left";
	final SHIFT_RIGHT = "Shift Group Right";
	final SOFT_DROP = "Soft Drop";
	final HARD_DROP = "Hard Drop";
	final ROTATE_LEFT = "Rotate Left";
	final ROTATE_RIGHT = "Rotate Right";
}

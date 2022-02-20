package game.actions;

import game.actions.Action;

enum abstract TrainingActions(Action) to String {
	final TOGGLE_EDIT_MODE = "Toggle Edit Mode";
	final PREVIOUS_STEP = "(EDIT) Prev. Chain Step + (PLAY) Undo";
	final NEXT_STEP = "(EDIT) Next Chain Step + (PLAY) Next Gelo Group";
	final PREVIOUS_COLOR = "(EDIT) Prev. Gelo Color";
	final NEXT_COLOR = "(EDIT) Next Gelo Color";
	final TOGGLE_MARKERS = "(EDIT) Toggle Gelos / Markers";
}

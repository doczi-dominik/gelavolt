package game.actions;

import input.InputType;
import game.actions.MenuActions;
import game.actions.GameActions;
import game.actions.TrainingActions;

final ActionInputTypes: Map<Action, InputType> = [
	PAUSE => PRESS, LEFT => REPEAT, RIGHT => REPEAT, DOWN => REPEAT, UP => REPEAT, BACK => PRESS, CONFIRM => PRESS, SHIFT_LEFT => HOLD, SHIFT_RIGHT => HOLD,
	SOFT_DROP => HOLD, HARD_DROP => PRESS, ROTATE_LEFT => PRESS, ROTATE_RIGHT => PRESS, TOGGLE_EDIT_MODE => PRESS, PREVIOUS_STEP => REPEAT,
	NEXT_STEP => REPEAT, PREVIOUS_COLOR => REPEAT, NEXT_COLOR => REPEAT, TOGGLE_MARKERS => PRESS
];

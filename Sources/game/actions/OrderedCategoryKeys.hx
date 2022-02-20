package game.actions;

import game.actions.MenuActions;
import game.actions.GameActions;
import game.actions.TrainingActions;

final OrderedCategoryKeys: Map<ActionCategory, Array<Action>> = [
	MENU => [PAUSE, LEFT, RIGHT, DOWN, UP, BACK, CONFIRM],
	GAME => [SHIFT_LEFT, SHIFT_RIGHT, SOFT_DROP, HARD_DROP, ROTATE_LEFT, ROTATE_RIGHT],
	TRAINING => [
		TOGGLE_EDIT_MODE,
		PREVIOUS_STEP,
		NEXT_STEP,
		PREVIOUS_COLOR,
		NEXT_COLOR,
		TOGGLE_MARKERS
	]
];

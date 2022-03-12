package game.actions;

enum abstract Action(String) from String to String {
	public static function getValues(): Array<Action> {
		return [
			PAUSE, LEFT, RIGHT, DOWN, UP, BACK, CONFIRM, SHIFT_LEFT, SHIFT_RIGHT, SOFT_DROP, HARD_DROP, ROTATE_LEFT, ROTATE_RIGHT, TOGGLE_EDIT_MODE,
			PREVIOUS_STEP, NEXT_STEP, PREVIOUS_COLOR, NEXT_COLOR, TOGGLE_MARKERS
		];
	}

	// Menu Actions
	final PAUSE;
	final LEFT;
	final RIGHT;
	final DOWN;
	final UP;
	final BACK;
	final CONFIRM;
	// Game Actions
	final SHIFT_LEFT;
	final SHIFT_RIGHT;
	final SOFT_DROP;
	final HARD_DROP;
	final ROTATE_LEFT;
	final ROTATE_RIGHT;
	// Training Actions
	final TOGGLE_EDIT_MODE;
	final PREVIOUS_STEP;
	final NEXT_STEP;
	final PREVIOUS_COLOR;
	final NEXT_COLOR;
	final TOGGLE_MARKERS;
}

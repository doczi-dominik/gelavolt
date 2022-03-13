package game.actions;

enum abstract Action(String) from String to String {
	public static function getValues(): Array<Action> {
		return [
			PAUSE, MENU_LEFT, MENU_RIGHT, MENU_DOWN, MENU_UP, BACK, CONFIRM, SHIFT_LEFT, SHIFT_RIGHT, SOFT_DROP, HARD_DROP, ROTATE_LEFT, ROTATE_RIGHT,
			TOGGLE_EDIT_MODE, EDIT_LEFT, EDIT_RIGHT, EDIT_DOWN, EDIT_UP, EDIT_SET, EDIT_CLEAR, PREVIOUS_STEP, NEXT_STEP, PREVIOUS_COLOR, NEXT_COLOR,
			PREVIOUS_GROUP, NEXT_GROUP, TOGGLE_MARKERS
		];
	}

	// Menu Actions
	final PAUSE;
	final MENU_LEFT;
	final MENU_RIGHT;
	final MENU_DOWN;
	final MENU_UP;
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
	final EDIT_LEFT;
	final EDIT_RIGHT;
	final EDIT_DOWN;
	final EDIT_UP;
	final EDIT_SET;
	final EDIT_CLEAR;
	final PREVIOUS_STEP;
	final NEXT_STEP;
	final PREVIOUS_COLOR;
	final NEXT_COLOR;
	final PREVIOUS_GROUP;
	final NEXT_GROUP;
	final TOGGLE_MARKERS;
}

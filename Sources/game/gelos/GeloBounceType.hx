package game.gelos;

enum GeloBounceType {
	/**
	 * Stops the Gelo from bouncing.
	 */
	NONE;

	/**
	 * Simple bouncing animation, played on Gelos that fall less than one cell
	 * after splitting.
	 */
	TSU_SHORT;

	/**
	 * Simple bouncing animation, played on Gelos that fall more than one cell
	 * after splitting.
	 */
	TSU_LONG;

	/**
	 * PPF DS-like squishing animation. `FieldState` rendering completes the
	 * effect when `Rule.animation` is set to `FEVER`.
	 */
	FEVER;
}

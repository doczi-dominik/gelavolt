package side_setup;

// When casted to an Int, it can be used to represent the first, second and
// third quarters of the screen, where the slot headers are on the
// `SideSetupScreen`.
enum abstract InputSlot(Int) to Int {
	final LEFT = 1;
	final UNASSIGNED;
	final RIGHT;
}

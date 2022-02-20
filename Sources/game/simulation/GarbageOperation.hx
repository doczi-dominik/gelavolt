package game.simulation;

enum GarbageOperation {
	NOTHING;
	ATTACK(amount: Int);
	OFFSET(amount: Int);
	COUNTER(offsetAmount: Int, counterAmount: Int);
}

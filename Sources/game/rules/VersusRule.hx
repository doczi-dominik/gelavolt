package game.rules;

@:structInit
class VersusRule extends EndlessRule {
	@:s public var garbageDropLimit(default, null): Int;
	@:s public var garbageConfirmGracePeriod(default, null): Int;
}

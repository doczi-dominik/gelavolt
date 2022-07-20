package game.net;

import game.gamestatebuilders.GameStateBuilderType;
import game.rules.Rule;

@:structInit
class NetplayOptions implements hxbit.Serializable {
	public final rngSeed: Int;
	public final rule: Rule;
	public final builderType: GameStateBuilderType;
	public final isOnLeftSide: Bool;
}

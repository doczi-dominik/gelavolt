package game.score;

import game.rules.Rule;
import game.geometries.BoardOrientation;

@:structInit
class ScoreManagerOptions {
	public final rule: Rule;
	public final orientation: BoardOrientation;
}

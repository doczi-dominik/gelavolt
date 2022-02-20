package game.screens;

import game.rules.Rule;
import save_data.Profile;

@:structInit
class GameScreenOptions {
	public final rngSeed: Int;
	public final rule: Rule;
	public final primaryProfile: Profile;
}

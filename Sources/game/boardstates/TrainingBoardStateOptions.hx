package game.boardstates;

import auto_attack.AutoAttackManager;
import save_data.TrainingSettings;

@:structInit
class TrainingBoardStateOptions extends EndlessBoardStateOptions {
	public final trainingSettings: TrainingSettings;
	public final infoState: TrainingInfoBoardState;
	public final autoAttackManager: AutoAttackManager;
}

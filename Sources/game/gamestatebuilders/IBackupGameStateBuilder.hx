package game.gamestatebuilders;

import game.copying.ICopyFrom;
import game.mediators.SaveGameStateMediator;

interface IBackupGameStateBuilder extends IGameStateBuilder extends ICopyFrom {
	public var saveGameStateMediator(null, default): Null<SaveGameStateMediator>;

	public function copy(): IBackupGameStateBuilder;
}

package game.gamestatebuilders;

import game.copying.ICopyFrom;
import game.mediators.RollbackMediator;

interface INetplayGameStateBuilder extends IGameStateBuilder extends ICopyFrom {
	public var rollbackMediator(null, default): RollbackMediator;

	public function createBackupBuilder(): INetplayGameStateBuilder;
}

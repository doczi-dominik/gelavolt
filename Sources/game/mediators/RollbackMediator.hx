package game.mediators;

import game.net.logger.ISessionLogger;

@:structInit
class RollbackMediator {
	public final confirmFrame: Void->Void;
	public final logger: ISessionLogger;
	public final rollback: Void->Void;
}

package game.mediators;

@:structInit
class RollbackMediator {
	public final confirmFrame: Void->Void;
	public final rollback: Int->Void;
}

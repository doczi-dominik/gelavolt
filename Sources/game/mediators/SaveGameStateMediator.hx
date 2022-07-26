package game.mediators;

@:structInit
class SaveGameStateMediator {
	public var loadState: Int->Void;
	public var saveState: Void->Void;
}

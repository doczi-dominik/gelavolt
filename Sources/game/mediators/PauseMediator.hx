package game.mediators;

import input.IInputDevice;

@:structInit
class PauseMediator {
	public final pause: IInputDevice->Void;
	public final resume: Void->Void;
}

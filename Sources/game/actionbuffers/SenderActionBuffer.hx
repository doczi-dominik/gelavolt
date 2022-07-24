package game.actionbuffers;

import game.net.SessionManager;
import game.actionbuffers.LocalActionBuffer.LocalActionBufferOptions;

@:structInit
@:build(game.Macros.buildOptionsClass(SenderActionBuffer))
class SenderActionBufferOptions extends LocalActionBufferOptions {}

class SenderActionBuffer extends LocalActionBuffer {
	@inject final session: SessionManager;

	public function new(opts: SenderActionBufferOptions) {
		super(opts);

		Macros.initFromOpts();
	}

	override function setLatestAction(frame: Int, action: ActionSnapshot) {
		super.setLatestAction(frame, action);

		session.sendInput(frame, action.toBitField());
	}

	override function copyFrom(other: Dynamic) {}
}

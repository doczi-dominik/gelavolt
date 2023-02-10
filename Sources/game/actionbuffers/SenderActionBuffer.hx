package game.actionbuffers;

import game.net.SessionManager;
import game.actionbuffers.LocalActionBuffer.LocalActionBufferOptions;

@:structInit
@:build(game.Macros.buildOptionsClass(SenderActionBuffer))
class SenderActionBufferOptions extends LocalActionBufferOptions {}

class SenderActionBuffer extends LocalActionBuffer {
	@inject final session: SessionManager;

	var lastSentAction: Null<ActionSnapshot>;

	public function new(opts: SenderActionBufferOptions) {
		super(opts);

		Macros.initFromOpts();
	}

	override function update(): Null<ActionSnapshot> {
		final latestAction = super.update();
		final bf = latestAction.toBitField();

		if (isActive) {
			session.isInputIdle = bf == 0;
		} else {
			session.isInputIdle = true;
		}

		if (lastSentAction == null || latestAction.isNotEqual(lastSentAction)) {
			session.sendInput(frameCounter.value + frameDelay, bf);
			lastSentAction = latestAction;
		}

		return latestAction;
	}
}

package game.actionbuffers;

import game.actionbuffers.LocalActionBuffer.LocalActionBufferOptions;

private enum abstract Mode(Int) {
	final REPLAY;
	final TAKE_CONTROL;
}

@:structInit
@:build(game.Macros.buildOptionsClass(ReplayActionBuffer))
class ReplayActionBufferOptions extends LocalActionBufferOptions {
	public final replayData: ReplayData;
}

class ReplayActionBuffer extends LocalActionBuffer {
	public var mode: Mode;

	public function new(opts: ReplayActionBufferOptions) {
		super(opts);

		for (f => d in opts.replayData) {
			actions[f] = ActionSnapshot.fromBitField(d);
		}

		mode = REPLAY;
	}

	override function update() {
		if (mode == REPLAY)
			return getAction(frameCounter.value);

		return super.update();
	}
}

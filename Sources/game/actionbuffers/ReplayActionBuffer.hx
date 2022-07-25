package game.actionbuffers;

import game.actionbuffers.LocalActionBuffer.LocalActionBufferOptions;

private enum abstract Mode(Int) {
	final REPLAY;
	final TAKE_CONTROL;
}

@:structInit
@:build(game.Macros.buildOptionsClass(ReplayActionBuffer))
class ReplayActionBufferOptions extends LocalActionBufferOptions {}

class ReplayActionBuffer extends LocalActionBuffer {
	@inject final replayData: ReplayData;

	public var mode: Mode;

	public function new(opts: ReplayActionBufferOptions) {
		super(opts);

		replayData = opts.replayData;

		mode = REPLAY;
	}

	override function update() {
		if (mode == REPLAY) {
			final current = replayData[frameCounter.value];

			if (current == null)
				return;

			latestAction = ActionSnapshot.fromBitField(current);

			return;
		}

		super.update();
	}
}

package game.actionbuffers;

import game.mediators.FrameCounter;

private enum abstract Mode(Int) {
	final REPLAY;
	final TAKE_CONTROL;
}

class ReplayActionBuffer extends LocalActionBuffer {
	final replayData: ReplayData;

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

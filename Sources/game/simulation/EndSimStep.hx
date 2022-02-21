package game.simulation;

import kha.graphics2.Graphics;

class EndSimStep extends SimulationStep {
	public final chainInfo: ChainInfo;

	public function new(opts: EndSimStepOptions) {
		super(END, opts);

		chainInfo = opts.chainInfo;
	}

	override function renderLabel(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Purple, SimulationStep.LABEL_SIZE);
		renderTitle(g, y, "End");
	}

	override function renderCard(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Purple, SimulationStep.CARD_SIZE);
		renderTitle(g, y, "End");

		g.fontSize = SimulationStep.CARD_FONT_SIZE;
		g.drawString('Chain: $chain', 12, y + cardRow(1));
		g.drawString('Total Garbage: ${chainInfo.totalGarbage}', 12, y + cardRow(2));
		g.drawString('All Clear: ${chainInfo.endsInAllClear}', 12, y + cardRow(3));
	}
}

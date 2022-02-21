package game.simulation;

import kha.graphics2.Graphics;

class EndSimStep extends SimulationStep {
	public final links: Array<LinkInfo>;
	public final totalGarbage: Int;
	public final endsInAllClear: Bool;
	public final isLastLinkPowerful: Bool;

	public function new(opts: EndSimStepOptions) {
		super(END, opts);

		links = opts.links;

		if (links.length == 0) {
			totalGarbage = 0;
			endsInAllClear = false;
			isLastLinkPowerful = false;

			return;
		}

		final lastLink = links[links.length - 1];

		totalGarbage = lastLink.accumulatedGarbage;
		endsInAllClear = opts.endsInAllClear;
		isLastLinkPowerful = lastLink.isPowerful;
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
		g.drawString('Total Garbage: ${totalGarbage}', 12, y + cardRow(2));
		g.drawString('All Clear: ${endsInAllClear}', 12, y + cardRow(3));
	}
}

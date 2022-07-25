package game.simulation;

import game.simulation.SimulationStep.SimulationStepOptions;
import kha.graphics2.Graphics;

class DropSimStep extends SimulationStep {
	public function new(opts: SimulationStepOptions) {
		super(DROP, opts);
	}

	override function copy(): SimulationStep {
		return new DropSimStep({
			chain: chain,
			fieldSnapshot: fieldSnapshot,
		});
	}

	override function renderLabel(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Blue, SimulationStep.LABEL_SIZE);
		renderTitle(g, y, "Drop");
	}

	override function renderCard(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Blue, SimulationStep.CARD_SIZE);
		renderTitle(g, y, "Drop");

		g.fontSize = SimulationStep.CARD_FONT_SIZE;
		g.drawString('Chain: $chain', 12, y + cardRow(1));
	}
}

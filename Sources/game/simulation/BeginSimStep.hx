package game.simulation;

import kha.graphics2.Graphics;

class BeginSimStep extends SimulationStep {
	public final sendsAllClearBonus: Bool;
	public final dropBonus: Float;
	public final groupIndex: Int;

	public function new(opts: BeginSimStepOptions) {
		super(BEGIN, opts);

		sendsAllClearBonus = opts.sendsAllClearBonus;
		dropBonus = opts.dropBonus;
		groupIndex = opts.groupIndex;
	}

	override function renderLabel(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Green, SimulationStep.LABEL_SIZE);
		renderTitle(g, y, "Begin");
	}

	override function renderCard(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Green, SimulationStep.CARD_SIZE);
		renderTitle(g, y, "Begin");

		g.fontSize = SimulationStep.CARD_FONT_SIZE;
		g.drawString('Chain: $chain', 12, y + cardRow(1));
		g.drawString('Drop bonus: $dropBonus', 12, y + cardRow(2));
		g.drawString('Sends AC Bonus: $sendsAllClearBonus', 12, y + cardRow(3));
		g.drawString('Group Index: $groupIndex', 12, y + cardRow(4));
	}
}

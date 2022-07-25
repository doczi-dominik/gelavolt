package game.simulation;

import game.simulation.SimulationStep.SimulationStepOptions;
import game.gelos.Gelo;
import game.gelogroups.GeloGroupData;
import kha.graphics2.Graphics;

@:structInit
@:build(game.Macros.buildOptionsClass(BeginSimStep))
class BeginSimStepOptions extends SimulationStepOptions {}

class BeginSimStep extends SimulationStep {
	@inject final groupData: Null<GeloGroupData>;

	@inject public final sendsAllClearBonus: Bool;
	@inject public final dropBonus: Float;
	@inject public final groupIndex: Null<Int>;

	public function new(opts: BeginSimStepOptions) {
		super(BEGIN, opts);

		game.Macros.initFromOpts();
	}

	override function copy(): SimulationStep {
		return new BeginSimStep({
			chain: chain,
			fieldSnapshot: fieldSnapshot,
			groupData: groupData,
			sendsAllClearBonus: sendsAllClearBonus,
			dropBonus: dropBonus,
			groupIndex: groupIndex
		});
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

		if (groupData != null) {
			g.drawString('Placed Gelo Group:', 12, y + cardRow(4));
			groupData.render(g, 12 + Gelo.SIZE * 2.5, y + cardRow(5) + Gelo.SIZE * 2.5);
		}
	}
}

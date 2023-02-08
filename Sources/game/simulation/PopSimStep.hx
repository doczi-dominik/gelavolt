package game.simulation;

import game.garbage.trays.IGarbageTray;
import game.simulation.SimulationStep.SimulationStepOptions;
import kha.Assets;
import game.geometries.BoardGeometries;
import kha.graphics2.Graphics;
import game.fields.FieldPopInfo;

@:structInit
@:build(game.Macros.buildOptionsClass(PopSimStep))
class PopSimStepOptions extends SimulationStepOptions {}

class PopSimStep extends SimulationStep {
	@inject final garbageDisplay: IGarbageTray;
	@inject final accumulatedDisplay: IGarbageTray;

	@inject public final popInfo: FieldPopInfo;
	@inject public final linkInfo: LinkInfo;

	public function new(opts: PopSimStepOptions) {
		super(POP, opts);

		game.Macros.initFromOpts();
	}

	override function copy(): SimulationStep {
		return new PopSimStep({
			chain: chain,
			fieldSnapshot: fieldSnapshot.copy(),
			garbageDisplay: garbageDisplay.copy(),
			accumulatedDisplay: accumulatedDisplay.copy(),
			popInfo: popInfo.copy(),
			linkInfo: linkInfo
		});
	}

	override function renderLabel(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Yellow, SimulationStep.LABEL_SIZE);
		renderTitle(g, y, "Pop");

		final chainStr = '$chain-CHAIN!';
		final width = Assets.fonts.Pixellari.width(SimulationStep.TITLE_FONT_SIZE, chainStr);
		final x = BoardGeometries.WIDTH - 12 - width;

		g.drawString(chainStr, x, y + 12);
	}

	override function renderCard(g: Graphics, y: Float, alpha: Float) {
		renderBackground(g, y, Yellow, SimulationStep.CARD_SIZE);
		renderTitle(g, y, "Pop");

		g.fontSize = SimulationStep.CARD_FONT_SIZE;

		// Dunno why but pushTransformation messed everything up
		g.drawString('Chain: $chain', 12, y + cardRow(1));
		g.drawString('Chain Power: ${linkInfo.chainPower}', 12, y + cardRow(2));
		g.drawString('Group Bonus: ${linkInfo.groupBonus}', 12, y + cardRow(3));
		g.drawString('Color Bonus: ${linkInfo.colorBonus}', 12, y + cardRow(4));
		g.drawString('Pops: ${linkInfo.clearCount}', 12, y + cardRow(5));
		g.drawString('Score: ${linkInfo.score}', 12, y + cardRow(6));
		g.drawString('Garbage: ${linkInfo.garbage}', 12, y + cardRow(7));

		garbageDisplay.render(g, 0, y + cardRow(8), alpha);

		g.drawString('Accum. Garbage: ${linkInfo.accumulatedGarbage}', 12, y + cardRow(10));

		accumulatedDisplay.render(g, 0, y + cardRow(11), alpha);
	}
}

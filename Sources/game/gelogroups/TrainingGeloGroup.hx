package game.gelogroups;

import game.rules.AnimationsType;
import game.rules.PhysicsType;
import game.gelogroups.GeloGroup.GeloGroupOptions;
import game.gelos.GeloColor;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import game.gelos.Gelo;
import kha.Color;
import save_data.TrainingSettings;

using utils.GraphicsExtension;

@:structInit
@:build(game.Macros.buildOptionsClass(TrainingGeloGroup))
class TrainingGeloGroupOptions extends GeloGroupOptions {}

class TrainingGeloGroup extends GeloGroup {
	static final BLIND_MODE_COLOR = Color.fromValue(0xFF666666);

	@inject final trainingSettings: TrainingSettings;

	public function new(opts: TrainingGeloGroupOptions) {
		super(opts);

		game.Macros.initFromOpts();
	}

	override function getPrimaryColor(geloColor: GeloColor) {
		return trainingSettings.groupBlindMode ? BLIND_MODE_COLOR : super.getPrimaryColor(geloColor);
	}

	override function renderGelo(g: Graphics, g4: Graphics4, x: Float, y: Float, alpha: Float, gelo: Gelo) {
		if (trainingSettings.groupBlindMode) {
			g.color = BLIND_MODE_COLOR;
			g.fillCircle(x, y, Gelo.HALFSIZE, 16);
			g.color = White;

			return;
		}

		super.renderGelo(g, g4, x, y, alpha, gelo);
	}
}

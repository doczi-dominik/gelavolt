package game;

import game.copying.ICopyFrom;
import kha.Color;
import game.rules.Rule;
import game.geometries.BoardGeometries;
import game.geometries.BoardOrientation;
import kha.Assets;
import kha.math.FastMatrix3;
import kha.Font;
import kha.graphics2.Graphics;
import utils.Utils.shadowDrawString;
import utils.Utils.lerp;
import game.simulation.LinkInfo;

using StringTools;

@:structInit
@:build(game.Macros.buildOptionsClass(ScoreManager))
class ScoreManagerOptions {}

class ScoreManager implements ICopyFrom {
	@inject final rule: Rule;
	@inject final orientation: BoardOrientation;

	final scoreFont: Font;
	final scoreFontSize: Int;
	final scoreTextWidth: Float;
	final scoreTextHeight: Float;

	final formulaFontSize: Int;
	final formulaTextHeight: Float;
	final formulaTextY: Float;

	final actionFont: Font;
	final actionFontSize: Int;
	final actionTextHeight: Float;
	@copy var actionTextColor: Color;

	var scoreScaleY: Float;

	@copy var formulaText: String;
	@copy var formulaTextWidth: Float;
	@copy var lastFormulaT: Int;
	@copy var formulaT: Int;
	@copy var showChainFormula: Bool;

	@copy var actionText: String;
	@copy var actionTextT: Int;
	@copy var actionTextCharacters: Int;
	@copy var showActionText: Bool;

	@copy public var score(default, null): Float;
	@copy public var dropBonus(default, null): Float;

	public function new(opts: ScoreManagerOptions) {
		game.Macros.initFromOpts();

		scoreFont = Assets.fonts.DigitalDisco;
		scoreFontSize = 52;
		scoreTextWidth = scoreFont.width(scoreFontSize, "00000000");
		scoreTextHeight = scoreFont.height(scoreFontSize);

		formulaFontSize = 34;
		formulaTextHeight = scoreFont.height(formulaFontSize);

		formulaTextY = -scoreTextHeight / 2 + scoreTextHeight - formulaTextHeight;

		actionFont = Assets.fonts.ka1;
		actionFontSize = 44;
		actionTextHeight = actionFont.height(actionFontSize);

		scoreScaleY = 1;

		showChainFormula = false;

		showActionText = false;

		score = 0;
		dropBonus = 0;
	}

	function renderScore(g: Graphics) {
		g.font = scoreFont;
		g.fontSize = scoreFontSize;

		shadowDrawString(g, 6, Black, White, '${Math.floor(score)}'.lpad("0", 8), 6, -scoreTextHeight / 2 + 6);
	}

	function updateChainFormula() {
		if (formulaT == 60) {
			formulaT = 0;
			showChainFormula = false;
		} else {
			formulaT++;
		}
	}

	function renderChainFormula(g: Graphics, x: Float, alpha: Float) {
		final lerpedT = lerp(lastFormulaT, formulaT, alpha);

		g.fontSize = formulaFontSize;

		g.pushOpacity(Math.sin(lerpedT / 15));
		shadowDrawString(g, 4, Black, Cyan, formulaText, x - 4, formulaTextY - 4);
		g.popOpacity();
	}

	function updateActionText() {
		if (actionTextT <= 5) {
			// Make the regular score display squash and disappear
			scoreScaleY -= 1 / 6;
		} else if (15 < actionTextT && actionTextT <= 45) {
			// Slowly spell out the action text
			actionTextCharacters = Std.int(lerp(0, actionText.length, (actionTextT - 15) / 20));
		} else if (55 < actionTextT && actionTextT <= 61) {
			// Restore the score display
			scoreScaleY += 1 / 6;
		} else if (61 < actionTextT) {
			showActionText = false;
		}

		actionTextT++;
	}

	function renderActionText(g: Graphics, x: Float) {
		g.font = actionFont;
		g.fontSize = actionFontSize;

		g.pushOpacity(1 - scoreScaleY);
		shadowDrawString(g, 6, Black, actionTextColor, actionText.substr(0, actionTextCharacters), x, -scoreTextHeight / 2 + 6);
		g.popOpacity();

		g.color = White;
	}

	public function addScoreFromLink(info: LinkInfo) {
		score += info.score;

		formulaText = '${info.clearCount * 10} X ${info.chainPower + info.groupBonus + info.colorBonus}';
		formulaTextWidth = scoreFont.width(formulaFontSize, formulaText);
		formulaT = 0;
		showChainFormula = true;
	}

	public function addDropBonus() {
		score += rule.softDropBonus;
		dropBonus += rule.softDropBonus;
	}

	public function resetDropBonus() {
		dropBonus = 0;
	}

	public function displayActionText(text: String, color: Color) {
		actionText = text;
		actionTextT = 0;
		scoreScaleY = 1;
		actionTextCharacters = 0;
		actionTextColor = color;
		showActionText = true;
	}

	public function update() {
		lastFormulaT = formulaT;

		if (showActionText)
			updateActionText();
		if (showChainFormula)
			updateChainFormula();
	}

	public function render(g: Graphics, y: Float, alpha: Float) {
		var scoreX = switch (orientation) {
			case LEFT: BoardGeometries.WIDTH - scoreTextWidth;
			case RIGHT: 0;
		}

		final transl = FastMatrix3.translation(scoreX, y);
		final scale = FastMatrix3.scale(1, scoreScaleY);

		g.pushTransformation(g.transformation.multmat(transl));
		g.pushTransformation(g.transformation.multmat(scale));

		renderScore(g);

		final formulaX = switch (orientation) {
			case LEFT: -scoreX;
			case RIGHT: BoardGeometries.WIDTH - formulaTextWidth;
		}

		if (showChainFormula) {
			renderChainFormula(g, formulaX, alpha);
		}

		g.popTransformation();

		if (showActionText) {
			renderActionText(g, formulaX);
		}

		g.popTransformation();
	}
}

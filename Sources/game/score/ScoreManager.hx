package game.score;

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

class ScoreManager {
	final rule: Rule;
	final orientation: BoardOrientation;

	var scoreFont: Font;
	var scoreFontSize: Int;
	var scoreTextWidth: Float;
	var scoreTextHeight: Float;

	var formulaFontSize: Int;
	var formulaTextHeight: Float;
	var formulaTextY: Float;

	var actionFont: Font;
	var actionFontSize: Int;
	var actionTextHeight: Float;
	var actionTextY: Float;

	var scoreScaleY: Float;

	var formulaText: String;
	var formulaTextWidth: Float;
	var lastFormulaT: Int;
	var formulaT: Int;
	var showChainFormula: Bool;

	var actionText: String;
	var actionTextT: Int;
	var actionTextCharacters: Int;
	var showActionText: Bool;

	public var score(default, null): Float;
	public var dropBonus(default, null): Float;

	public function new(opts: ScoreManagerOptions) {
		rule = opts.rule;
		orientation = opts.orientation;

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
		actionTextY = formulaTextY;

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
		} else if (55 < actionTextT && actionTextT <= 60) {
			// Restore the score display
			scoreScaleY += 1 / 6;
		} else {
			showActionText = false;
		}

		actionTextT++;
	}

	function renderActionText(g: Graphics) {
		g.font = actionFont;
		g.fontSize = actionFontSize;

		g.pushOpacity(1 - scoreScaleY);
		shadowDrawString(g, 6, Black, Color.fromValue(0xFFFF1744), actionText.substr(0, actionTextCharacters), 0, actionTextY);
		g.popOpacity();
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

	public function displayActionText(text: String) {
		actionText = text;
		actionTextT = 0;
		scoreScaleY = 1;
		actionTextCharacters = 0;
		showActionText = true;
	}

	public function update() {
		lastFormulaT = formulaT;

		if (showActionText)
			updateActionText();
		if (showChainFormula)
			updateChainFormula();
	}

	// TODO: Suppy orientation in constr.
	public function render(g: Graphics, y: Float, alpha: Float) {
		var scoreX = switch (orientation) {
			case LEFT: BoardGeometries.WIDTH - scoreTextWidth;
			case RIGHT: 0;
		}

		final transform = FastMatrix3.translation(scoreX, y).multmat(FastMatrix3.scale(1, scoreScaleY));
		g.pushTransformation(g.transformation.multmat(transform));

		renderScore(g);

		if (showChainFormula) {
			final formulaX = switch (orientation) {
				case LEFT: -scoreX;
				case RIGHT: BoardGeometries.WIDTH - formulaTextWidth;
			}

			renderChainFormula(g, formulaX, alpha);
		}

		if (showActionText) {
			renderActionText(g);
		}

		g.popTransformation();
	}
}

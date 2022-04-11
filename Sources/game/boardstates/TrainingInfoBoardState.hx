package game.boardstates;

import auto_attack.AutoAttackManager;
import save_data.PrefsSettings;
import game.garbage.IGarbageManager;
import game.rules.Rule;
import utils.Utils;
import game.rules.MarginTimeManager;
import save_data.TrainingSettings;
import game.garbage.trays.GarbageTray;
import game.score.ScoreManager;
import game.simulation.ILinkInfoBuilder;
import kha.Color;
import game.geometries.BoardGeometries;
import game.simulation.PopSimStep;
import game.simulation.ChainSimulator;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;
import utils.Utils.shadowDrawString;

using StringTools;

@:access(game.rules.Rule)
class TrainingInfoBoardState implements IBoardState {
	static inline final TITLE_FONT_SIZE = 40;
	static inline final CARD_FONT_SIZE = 32;
	static inline final CARD_SIZE = 512;

	public static inline final GAME_INFO_X = -64;

	final geometries: BoardGeometries;
	final marginManager: MarginTimeManager;
	final rule: Rule;
	final linkBuilder: ILinkInfoBuilder;
	final trainingSettings: TrainingSettings;
	final chainAdvantageDisplay: GarbageTray;
	final afterCounterDisplay: GarbageTray;
	final garbageManager: IGarbageManager;
	final prefsSettings: PrefsSettings;
	final autoAttackManager: AutoAttackManager;

	final playerScoreManager: ScoreManager;
	final playerChainSim: ChainSimulator;

	final font: Font;
	final titleFontHeight: Float;
	final cardFontHeight: Float;
	final splitPercentageWidth: Float;

	var chain: Int;
	var chainLength: Int;

	var linkDamage: Int;
	var linkRemainder: Float;
	var linkStandardDamages: Array<Int>;

	var chainDamage: Int;
	var totalDamage: Int;

	var chainAdvantage: Int;
	var toCounterChain: Int;
	var counterDifference: Int;

	var groupCounter: Int;
	var ppsT: Int;

	var splitT: Int;

	var currentGreatSplits: Int;
	var currentOkaySplits: Int;
	var currentSlowSplits: Int;
	var currentSplitCounter: Int;

	var overallGreatSplits: Int;
	var overallOkaySplits: Int;
	var overallSlowSplits: Int;
	var overallSplitCounter: Int;

	var updateSplitT: Bool;
	var showSteps: Bool;

	var viewMin: Int;

	public var shouldUpdatePPST: Bool;

	public function new(opts: TrainingInfoBoardStateOptions) {
		geometries = opts.geometries;
		marginManager = opts.marginManager;
		rule = opts.rule;
		linkBuilder = opts.linkBuilder;
		trainingSettings = opts.trainingSettings;
		chainAdvantageDisplay = opts.chainAdvantageDisplay;
		afterCounterDisplay = opts.afterCounterDisplay;
		garbageManager = opts.garbageManager;
		prefsSettings = opts.prefsSettings;
		autoAttackManager = opts.autoAttackManager;

		playerScoreManager = opts.playerScoreManager;
		playerChainSim = opts.playerChainSim;

		font = Assets.fonts.Pixellari;
		titleFontHeight = font.height(TITLE_FONT_SIZE);
		cardFontHeight = font.height(CARD_FONT_SIZE);
		splitPercentageWidth = font.width(TITLE_FONT_SIZE, "000% ");

		chain = 0;
		chainLength = 0;

		linkDamage = 0;
		linkRemainder = 0;

		chainDamage = 0;
		totalDamage = 0;

		chainAdvantage = 0;
		toCounterChain = 1;
		counterDifference = 0;

		groupCounter = 0;
		ppsT = 0;

		splitT = 0;

		resetCurrentSplitStatistics();

		overallGreatSplits = 0;
		overallOkaySplits = 0;
		overallSlowSplits = 0;
		overallSplitCounter = 0;

		updateSplitT = false;
		showSteps = false;

		viewMin = 0;

		shouldUpdatePPST = true;
	}

	function gameRow(index: Int) {
		return titleFontHeight * index;
	}

	function getSplitCategory(): TrainingInfoSplitCategory {
		if (splitT <= 14)
			return GREAT;
		if (splitT <= 42)
			return OKAY;

		return SLOW;
	}

	function renderSplitPercentage(g: Graphics, x: Float, y: Float, color: Color, value: Int) {
		shadowDrawString(g, 3, Black, color, '$value% '.lpad(" ", 5), x, y);
	}

	function renderSplitStatistics(g: Graphics, title: String, y: Float, splitCounter: Int, great: Int, okay: Int, slow: Int) {
		final titleWidth = font.width(TITLE_FONT_SIZE, title);

		shadowDrawString(g, 3, Black, White, title, GAME_INFO_X, y);

		if (splitCounter == 0) {
			renderSplitPercentage(g, GAME_INFO_X + titleWidth, y, Green, 0);
			renderSplitPercentage(g, GAME_INFO_X + titleWidth + splitPercentageWidth, y, Yellow, 0);
			renderSplitPercentage(g, GAME_INFO_X + titleWidth + splitPercentageWidth * 2, y, Red, 0);

			return;
		}

		renderSplitPercentage(g, GAME_INFO_X + titleWidth, y, Green, Math.round(great / splitCounter * 100));
		renderSplitPercentage(g, GAME_INFO_X + titleWidth + splitPercentageWidth, y, Yellow, Math.round(okay / splitCounter * 100));
		renderSplitPercentage(g, GAME_INFO_X + titleWidth + splitPercentageWidth * 2, y, Red, Math.round(slow / splitCounter * 100));

		g.color = White;
	}

	function renderGameInfo(g: Graphics, alpha: Float) {
		g.fontSize = TITLE_FONT_SIZE;

		shadowDrawString(g, 3, Black, White, 'Chain: $chain / $chainLength', GAME_INFO_X, gameRow(-3));
		shadowDrawString(g, 3, Black, White, 'Remainder: $linkRemainder', GAME_INFO_X, gameRow(0));
		shadowDrawString(g, 3, Black, White, 'Damage: $chainDamage / $totalDamage', GAME_INFO_X, gameRow(1));

		shadowDrawString(g, 3, Black, White, 'Speed (PPS): ${Utils.limitDecimals(groupCounter / (ppsT / 60), 2)}', GAME_INFO_X, gameRow(3));

		// Font is not monospace ;(
		renderSplitStatistics(g, "Splits (ALL):  ", gameRow(4), overallSplitCounter, overallGreatSplits, overallOkaySplits, overallSlowSplits);

		renderSplitStatistics(g, "Splits (NOW): ", gameRow(5), currentSplitCounter, currentGreatSplits, currentOkaySplits, currentSlowSplits);

		final splitColor = switch (getSplitCategory()) {
			case GREAT:
				g.color = Green;
			case OKAY:
				g.color = Yellow;
			case SLOW:
				g.color = Red;
		}

		shadowDrawString(g, 3, Black, splitColor, '$splitT'.lpad(" ", 3), GAME_INFO_X, gameRow(6));
		g.fillRect(0, gameRow(6), splitT * 4, 32);

		g.color = White;

		shadowDrawString(g, 3, Black, White, 'Chain Standard Advantage: $chainAdvantage', GAME_INFO_X, gameRow(9));

		chainAdvantageDisplay.render(g, GAME_INFO_X, gameRow(10), alpha);

		shadowDrawString(g, 3, Black, White, 'To Counter: $toCounterChain ($counterDifference remains)', GAME_INFO_X, gameRow(12));

		afterCounterDisplay.render(g, GAME_INFO_X, gameRow(13), alpha);

		final targetPoints = marginManager.targetPoints;

		shadowDrawString(g, 3, Black, White, 'Target Pts (Margin T): $targetPoints (${Std.int(marginManager.marginTime / 60)})', GAME_INFO_X, gameRow(15));

		final dropBonus = Std.int(playerScoreManager.dropBonus);

		shadowDrawString(g, 3, Black, White, 'Drop bonus: $dropBonus (${Std.int(dropBonus / targetPoints)} garbo)', GAME_INFO_X, gameRow(16));

		if (!autoAttackManager.isPaused) {
			final autoAttackString = switch (autoAttackManager.state) {
				case WAITING: 'Auto-Attack WAITING: ${Std.int(autoAttackManager.timer / 60 + 1)}';
				case SENDING: 'Auto-Attack SENDING: ${autoAttackManager.chain}-CHAIN!';
			}

			shadowDrawString(g, 3, Black, White, autoAttackString, GAME_INFO_X, gameRow(18));
		} else {
			shadowDrawString(g, 3, Black, White, "Auto-Attack DISABLED", GAME_INFO_X, gameRow(18));
		}

		autoAttackManager.render(g, alpha);
	}

	function renderEditInfo(g: Graphics, alpha: Float) {
		final steps = playerChainSim.steps;

		final viewIndex = playerChainSim.viewIndex;

		for (i in 0...4) {
			final stepIndex = viewMin + i;
			final localIndex = viewIndex - viewMin;
			final step = steps[stepIndex];

			if (step == null)
				break;

			final offset = (i > localIndex) ? CARD_SIZE - 64 : 0;
			final y = 72 * i + offset;

			if (i == localIndex) {
				step.renderCard(g, y, alpha);
			} else {
				step.renderLabel(g, y, alpha);
			}
		}

		g.fontSize = CARD_FONT_SIZE;
		shadowDrawString(g, 3, Black, White, '${viewIndex + 1} / ${steps.length}', 0, BoardGeometries.HEIGHT);
	}

	public function resetCurrentSplitStatistics() {
		currentGreatSplits = 0;
		currentOkaySplits = 0;
		currentSlowSplits = 0;
		currentSplitCounter = 0;

		stopSplitTimer();
	}

	public inline function incrementGroupCounter() {
		++groupCounter;
	}

	public function startSplitTimer() {
		splitT = 0;
		updateSplitT = true;
	}

	public function stopSplitTimer() {
		updateSplitT = false;
	}

	public function saveSplitCategory() {
		switch (getSplitCategory()) {
			case GREAT:
				++currentGreatSplits;
				++overallGreatSplits;
			case OKAY:
				++currentOkaySplits;
				++overallOkaySplits;
			case SLOW:
				++currentSlowSplits;
				++overallSlowSplits;
		}

		++currentSplitCounter;
		++overallSplitCounter;
	}

	public function loadChain() {
		final latestChain = playerChainSim.latestChainCounter;

		if (latestChain == 0)
			return;

		if (trainingSettings.autoClear) {
			garbageManager.clear();
		}

		chain = 0;
		chainLength = latestChain;

		linkDamage = 0;
		linkStandardDamages = [];

		chainDamage = 0;
		totalDamage = playerChainSim.latestGarbageCounter;

		chainAdvantage = 0;
		toCounterChain = 0; // Also used as a chain link counter here
		var garbageCounter = 0;
		var remainder = 0.0;

		do {
			final link = linkBuilder.build({
				chain: ++toCounterChain,
				totalGarbage: garbageCounter,
				sendsAllClearBonus: false,
				garbageRemainder: remainder,
				dropBonus: 0,
				clearsByColor: [COLOR1 => rule.popCount, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0]
			});

			garbageCounter = link.accumulatedGarbage;
			remainder = link.garbageRemainder;

			linkStandardDamages.push(link.garbage);

			if (toCounterChain == chainLength) {
				chainAdvantage = totalDamage - garbageCounter;
			}
		} while (garbageCounter < totalDamage);

		counterDifference = garbageCounter - totalDamage;

		chainAdvantageDisplay.startAnimation(chainAdvantage);
		afterCounterDisplay.startAnimation(counterDifference);
	}

	public function updateChain(step: PopSimStep) {
		chain = step.chain;

		final linkInfo = step.linkInfo;

		linkDamage = linkInfo.garbage;
		linkRemainder = Utils.limitDecimals(linkInfo.garbageRemainder, 2);

		chainDamage = linkInfo.accumulatedGarbage;
	}

	public function showChainSteps() {
		viewMin = playerChainSim.viewIndex;
		showSteps = true;
	}

	public function hideChainSteps() {
		loadChain();
		showSteps = false;
	}

	public function onViewChainStep() {
		if (playerChainSim.viewIndex > viewMin + 3) {
			viewMin++;
		}

		if (playerChainSim.viewIndex < viewMin) {
			viewMin--;
		}
	}

	public function update() {
		if (updateSplitT) {
			splitT++;
		}

		if (shouldUpdatePPST) {
			ppsT++;
		}

		autoAttackManager.update();
		garbageManager.update();
	}

	public function renderScissored(g: Graphics, g4: Graphics4, alpha: Float) {}

	public function renderFloating(g: Graphics, g4: Graphics4, alpha: Float) {
		g.font = font;

		if (showSteps) {
			renderEditInfo(g, alpha);
		} else {
			renderGameInfo(g, alpha);
		}

		final garbageTrayPos = geometries.garbageTray;

		garbageManager.render(g, garbageTrayPos.x, garbageTrayPos.y, alpha);
	}
}

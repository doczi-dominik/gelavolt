package game.boardstates;

import game.garbage.IGarbageManager;
import game.rules.Rule;
import utils.Utils;
import game.fields.Field;
import game.rules.MarginTimeManager;
import game.ChainCounter;
import game.gelos.GeloColor;
import kha.math.Random;
import save_data.TrainingSave;
import game.garbage.trays.GarbageTray;
import game.score.ScoreManager;
import game.simulation.ILinkInfoBuilder;
import kha.Color;
import game.garbage.GarbageManager;
import game.geometries.BoardGeometries;
import game.simulation.PopSimStep;
import game.simulation.ChainSimulator;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import kha.graphics4.Graphics as Graphics4;

using StringTools;

@:access(game.rules.Rule)
class TrainingInfoBoardState implements IBoardState {
	static inline final TITLE_FONT_SIZE = 40;
	static inline final CARD_FONT_SIZE = 32;
	static inline final CARD_SIZE = 512;

	final geometries: BoardGeometries;
	final marginManager: MarginTimeManager;
	final rule: Rule;
	final rng: Random;
	final linkBuilder: ILinkInfoBuilder;
	final trainingSave: TrainingSave;
	final chainAdvantageDisplay: GarbageTray;
	final afterCounterDisplay: GarbageTray;
	final autoChainCounter: ChainCounter;
	final garbageManager: IGarbageManager;

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

	var autoAttackState: AutoAttackState;
	var autoAttackT: Int;
	var autoAttackChain: Int;
	var autoAttackMaxChain: Int;
	var autoAttackGarbage: Int;
	var autoAttackRemainder: Float;

	var viewMin: Int;

	public function new(opts: TrainingInfoBoardStateOptions) {
		geometries = opts.geometries;
		marginManager = opts.marginManager;
		rule = opts.rule;
		rng = opts.rng;
		linkBuilder = opts.linkBuilder;
		trainingSave = opts.trainingSave;
		chainAdvantageDisplay = opts.chainAdvantageDisplay;
		afterCounterDisplay = opts.afterCounterDisplay;
		autoChainCounter = opts.autoChainCounter;
		garbageManager = opts.garbageManager;

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

		splitT = 0;

		resetCurrentSplitStatistics();

		overallGreatSplits = 0;
		overallOkaySplits = 0;
		overallSlowSplits = 0;
		overallSplitCounter = 0;

		updateSplitT = false;
		showSteps = false;

		resetAutoAttackWaitingState();

		viewMin = 0;
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

	function updateWaitingAutoAttack() {
		if (autoAttackT == 0) {
			garbageManager.clear();
			autoAttackState = SENDING;
			autoAttackT = 0;
			autoAttackChain = 0;
			autoAttackMaxChain = rng.GetIn(trainingSave.minAttackChain, trainingSave.maxAttackChain);
		} else {
			--autoAttackT;
		}
	}

	function updateSendingAutoAttack() {
		if (autoAttackT == 0) {
			final clearsByColor = [COLOR1 => 0, COLOR2 => 0, COLOR3 => 0, COLOR4 => 0, COLOR5 => 0];

			final colorCount = rng.GetIn(trainingSave.minAttackColors, trainingSave.maxAttackColors);

			for (i in 0...colorCount) {
				clearsByColor[i] = rule.popCount + rng.GetIn(trainingSave.minAttackGroupDiff, trainingSave.maxAttackGroupDiff);
			}

			final link = linkBuilder.build({
				chain: ++autoAttackChain,
				clearsByColor: clearsByColor,
				totalGarbage: autoAttackGarbage,
				garbageRemainder: autoAttackRemainder,
				dropBonus: 0,
				sendsAllClearBonus: false
			});

			autoAttackGarbage = link.accumulatedGarbage;
			autoAttackRemainder = link.garbageRemainder;

			garbageManager.sendGarbage(link.garbage, [{x: 0, y: Std.int(gameRow(20)), color: COLOR1}]);

			autoAttackT = 80;

			autoChainCounter.startAnimation(autoAttackChain, {x: 112, y: gameRow(20)}, link.isPowerful);

			if (autoAttackChain == autoAttackMaxChain) {
				garbageManager.confirmGarbage(autoAttackGarbage);

				resetAutoAttackWaitingState();
			}
		} else {
			--autoAttackT;
		}
	}

	function renderSplitPercentage(g: Graphics, x: Float, y: Float, color: Color, value: Int) {
		g.color = color;
		g.drawString('$value% '.lpad(" ", 5), x, y);
	}

	function renderSplitStatistics(g: Graphics, title: String, y: Float, splitCounter: Int, great: Int, okay: Int, slow: Int) {
		final titleWidth = font.width(TITLE_FONT_SIZE, title);

		g.drawString(title, 0, y);

		if (splitCounter == 0) {
			renderSplitPercentage(g, titleWidth, y, Green, 0);
			renderSplitPercentage(g, titleWidth + splitPercentageWidth, y, Yellow, 0);
			renderSplitPercentage(g, titleWidth + splitPercentageWidth * 2, y, Red, 0);

			return;
		}

		renderSplitPercentage(g, titleWidth, y, Green, Math.round(great / splitCounter * 100));
		renderSplitPercentage(g, titleWidth + splitPercentageWidth, y, Yellow, Math.round(okay / splitCounter * 100));
		renderSplitPercentage(g, titleWidth + splitPercentageWidth * 2, y, Red, Math.round(slow / splitCounter * 100));

		g.color = White;
	}

	function renderGameInfo(g: Graphics, alpha: Float) {
		g.fontSize = TITLE_FONT_SIZE;

		g.drawString('Chain: $chain / $chainLength', 0, gameRow(-3));
		g.drawString('Remainder: $linkRemainder', 0, gameRow(0));

		g.drawString('Damage: $chainDamage / $totalDamage', 0, gameRow(1));

		// Font is not monospace ;(
		renderSplitStatistics(g, "Splits (ALL):  ", gameRow(3), overallSplitCounter, overallGreatSplits, overallOkaySplits, overallSlowSplits);

		renderSplitStatistics(g, "Splits (NOW): ", gameRow(4), currentSplitCounter, currentGreatSplits, currentOkaySplits, currentSlowSplits);

		switch (getSplitCategory()) {
			case GREAT:
				g.color = Green;
			case OKAY:
				g.color = Yellow;
			case SLOW:
				g.color = Red;
		}

		g.drawString('$splitT'.lpad(" ", 3), 0, gameRow(5));
		g.fillRect(64, gameRow(5), splitT * 4, 32);

		g.color = White;

		g.drawString('Chain Standard Advantage: $chainAdvantage', 0, gameRow(8));

		chainAdvantageDisplay.render(g, 0, gameRow(9), alpha);

		g.drawString('To Counter: $toCounterChain ($counterDifference remains)', 0, gameRow(11));

		afterCounterDisplay.render(g, 0, gameRow(12), alpha);

		final targetPoints = marginManager.targetPoints;

		g.drawString('Target Points: $targetPoints', 0, gameRow(14));
		g.drawString('Margin Time: ${Std.int(marginManager.marginTime / 60)}', 0, gameRow(15));

		final dropBonus = Std.int(playerScoreManager.dropBonus);

		g.drawString('Drop bonus: $dropBonus (${Std.int(dropBonus / targetPoints)} garbo)', 0, gameRow(16));

		if (trainingSave.autoAttack) {
			final autoAttackString = switch (autoAttackState) {
				case WAITING: 'Auto-Attack WAITING: ${Std.int(autoAttackT / 60 + 1)}';
				case SENDING: 'Auto-Attack SENDING: $autoAttackMaxChain-CHAIN!';
			}

			g.drawString(autoAttackString, 0, gameRow(17));
		} else {
			g.drawString("Auto-Attack DISABLED", 0, gameRow(17));
		}
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
		g.drawString('${viewIndex + 1} / ${steps.length}', 0, BoardGeometries.HEIGHT);
	}

	public function resetAutoAttackWaitingState() {
		autoAttackState = WAITING;
		autoAttackT = rng.GetIn(trainingSave.minAttackTime, trainingSave.maxAttackTime) * 60;
		autoAttackGarbage = 0;
		autoAttackRemainder = 0;
	}

	public function resetCurrentSplitStatistics() {
		currentGreatSplits = 0;
		currentOkaySplits = 0;
		currentSlowSplits = 0;
		currentSplitCounter = 0;
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

		if (trainingSave.autoClear) {
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

		if (trainingSave.autoAttack && !showSteps) {
			switch (autoAttackState) {
				case WAITING:
					updateWaitingAutoAttack();
				case SENDING:
					updateSendingAutoAttack();
			}
		}

		autoChainCounter.update();
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

		autoChainCounter.render(g, alpha);
		garbageManager.render(g, garbageTrayPos.x, garbageTrayPos.y, alpha);
	}
}

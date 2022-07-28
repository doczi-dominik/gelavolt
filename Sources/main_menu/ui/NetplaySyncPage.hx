package main_menu.ui;

import game.actionbuffers.ReceiveActionBuffer;
import game.actionbuffers.SenderActionBuffer;
import game.gamestatebuilders.VersusGameStateBuilder;
import game.screens.GameScreen;
import Screen.GlobalScreenSwitcher;
import kha.System;
import game.copying.CopyableRNG;
import game.mediators.FrameCounter;
import game.net.SessionManager;
import kha.graphics2.Graphics;
import input.AnyInputDevice;
import kha.Assets;
import ui.ControlHint;
import ui.Menu;
import kha.Font;
import ui.IMenuPage;

class NetplaySyncPage implements IMenuPage {
	static inline final FONT_SIZE = 48;

	final font: Font;

	var menu: Menu;
	var fontSize: Int;
	var fontHeight: Float;

	var frameCounter: FrameCounter;
	var session: SessionManager;

	var lastSleepFrames: Int;
	var sleepCounter: Int;

	public final header: String;

	public var controlHints(default, null): Array<ControlHint>;

	public function new() {
		font = Assets.fonts.Pixellari;

		header = "Sync Test";

		controlHints = [{actions: [BACK], description: "Back"}];
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		frameCounter = new FrameCounter();
		session = new SessionManager({
			serverUrl: "192.168.1.159:2424",
			roomCode: "test12345",
			frameCounter: frameCounter,
		});

		session.onBegin = function(options) {
			switch (options.builderType) {
				case VERSUS:
					GlobalScreenSwitcher.switchScreen(new GameScreen(new VersusGameStateBuilder({
						frameCounter: frameCounter,
						rule: options.rule,
						rngSeed: options.rngSeed,
						leftActionBuffer: new SenderActionBuffer({
							session: session,
							frameCounter: frameCounter,
							inputDevice: menu.inputDevice,
							frameDelay: 2
						}),
						rightActionBuffer: new ReceiveActionBuffer({
							session: session,
							frameCounter: frameCounter
						})
					})));
				default:
			}
		}
	}

	public function update() {
		final anyInput = AnyInputDevice.instance;

		if (anyInput.getAction(BACK)) {
			menu.popPage();

			return;
		}

		session.waitForRunning();

		if (sleepCounter > 0) {
			sleepCounter--;
			return;
		}

		switch (session.state) {
			case SYNCING | BEGINNING:
				frameCounter.update();
			default:
		}

		sleepCounter = session.getSleepFrames();
		if (sleepCounter > 0)
			lastSleepFrames = sleepCounter;
	}

	public function render(g: Graphics, x: Float, y: Float) {
		g.font = font;
		g.fontSize = fontSize;

		g.drawString('State: ${session.state}', x, y);
		g.drawString('Avg RTT: ${session.averageRTT}', x, y + fontHeight);

		final t = frameCounter.value;

		g.drawString('T: $t', x, y + fontHeight * 2);
		g.drawString('Last sleep frames: $lastSleepFrames', x, y + fontHeight * 3);
		g.drawString('Beginning on: ${session.beginFrame}', x, y + fontHeight * 4);

		if (t % 500 == 0 && t > 0) {
			g.color = Red;
			g.fillRect(0, 0, 1920, 1080);
		}

		g.color = White;
	}
}

package main_menu.ui;

import kha.Scheduler;
import kha.System;
import kha.math.Random;
import game.mediators.FrameCounter;
import game.net.SessionManager;
import kha.graphics2.Graphics;
import input.AnyInputDevice;
import kha.Assets;
import ui.ControlDisplay;
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

	public var controlDisplays(default, null): Array<ControlDisplay>;

	public function new() {
		font = Assets.fonts.Pixellari;

		header = "Sync Test";

		controlDisplays = [{actions: [BACK], description: "Back"}];
	}

	public function onResize() {
		fontSize = Std.int(FONT_SIZE * menu.scaleManager.smallerScale);
		fontHeight = font.height(fontSize);
	}

	public function onShow(menu: Menu) {
		this.menu = menu;

		frameCounter = new FrameCounter();
		session = new SessionManager({
			serverUrl: "localhost:2424",
			roomCode: "test12345",
			frameCounter: frameCounter,
			rule: {},
			rngSeed: 0,
			localInputDevice: menu.inputDevice
		});

		final r = new Random(Std.int(System.time * 1000000));

		for (_ in 0...r.GetIn(0, 3) * 10) {
			frameCounter.update();
		}
	}

	public function update() {
		final anyInput = AnyInputDevice.instance;

		if (anyInput.getAction(BACK)) {
			menu.popPage();

			return;
		}

		if (sleepCounter > 0) {
			sleepCounter--;
			return;
		}

		if (session.state == SYNCING) {
			frameCounter.update();
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

		if (t % 500 == 0 && t > 0) {
			g.color = Red;
			g.fillRect(0, 0, 1920, 1080);
		}

		g.color = White;
	}
}

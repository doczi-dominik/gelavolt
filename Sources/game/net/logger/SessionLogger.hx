package game.net.logger;

import game.mediators.FrameCounter;
#if js
import js.Browser;
import js.html.File;
import js.html.URL;

using DateTools;
#end

class SessionLogger implements ISessionLogger {
	final frameCounter: FrameCounter;
	final setupLog: Array<String>;
	final gameLog: Array<String>;

	public var useGameLog: Bool;

	public function new(frameCounter: FrameCounter) {
		this.frameCounter = frameCounter;
		setupLog = [];
		gameLog = [];

		useGameLog = false;
	}

	inline function pushSetup(message: String) {
		setupLog.push(message);
	}

	inline function pushGame(message: String) {
		gameLog.push(message);

		if (gameLog.length > 256) {
			gameLog.shift();
		}
	}

	public function push(message: String) {
		if (useGameLog) {
			pushGame(message);

			return;
		}

		pushSetup(message);
	}

	public function download() {
		#if js
		final filename = 'netplay-${Date.now().format("%Y-%m-%d_%H-%M")}.gvl';
		final file = new File(setupLog.concat(gameLog), filename);
		final uri = URL.createObjectURL(file);

		final el = Browser.document.createAnchorElement();

		el.href = uri;
		el.setAttribute("download", filename);
		el.click();
		#end
	}
}

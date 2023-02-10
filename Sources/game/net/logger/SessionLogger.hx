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
	final log: Array<String>;

	var index: Int;
	var indexMin: Int;
	var indexLimitEnabled: Bool;

	public function new(frameCounter: FrameCounter) {
		this.frameCounter = frameCounter;
		log = [];

		index = 0;
		indexMin = 0;
		indexLimitEnabled = false;
	}

	public function enableRingBuffer() {
		indexLimitEnabled = true;
		indexMin = index;
		index = 0;
	}

	public function disableRingBuffer() {
		indexLimitEnabled = false;
	}

	public function push(message: String) {
		final str = '${frameCounter.value}: $message\n';

		if (indexLimitEnabled) {
			log[indexMin + index] = str;
			index = (index + 1) % 64;

			return;
		}

		log.push(str);
		index++;
	}

	public function download() {
		#if js
		final filename = 'netplay-${Date.now().format("%Y-%m-%d_%H-%M")}.gvl';
		final file = new File(log, filename);
		final uri = URL.createObjectURL(file);

		final el = Browser.document.createAnchorElement();

		el.href = uri;
		el.setAttribute("download", filename);
		el.click();
		#end
	}
}

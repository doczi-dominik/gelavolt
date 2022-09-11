package;

import input.AnyInputDevice;
import save_data.SaveManager;
import input.InputDevice;
import save_data.Profile;
import kha.Assets;
import kha.Scheduler;
import kha.System;
#if kha_html5
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import kha.Macros;
import js.html.FileReader;
import js.html.DragEvent;
import js.Browser;
import lobby.LobbyPage;
#else
import kha.Window;
import sys.FileSystem;
import main_menu.MainMenuScreen;
import sys.io.File;
#end

using StringTools;

/**
 * The entry point. Responsible for setting up Kha and making the HTML5 canvas
 * full screen and resizable on targets that use HTML5.
 */
class Main {
	static final FIXED_UPDATE_DELTA = 1 / 60;

	static var accumulator = 0.0;
	static var lastT: Float;
	static var alpha: Float;

	#if kha_html5
	/**
	 * Makes the HTML5 canvas fullscreen and resizable.
	 */
	static function setFullHTML5Canvas(): Void {
		// make html5 canvas resizable
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		document.body.style.overflow = "hidden";
		var canvas: CanvasElement = cast document.getElementById(Macros.canvasId());
		canvas.style.display = "block";

		ScaleManager.addOnResizeCallback(() -> {
			canvas.width = Std.int(window.innerWidth);
			canvas.height = Std.int(window.innerHeight);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
		});
	}
	#end

	/**
	 * The entry point. Sets up Kha and the initial global state.
	 */
	public static function main() {
		#if kha_html5
		window.onresize = () -> {
			ScaleManager.screen.resize(window.innerWidth, window.innerHeight);
		};

		setFullHTML5Canvas();
		#end

		System.start({
			title: "Project GelaVolt",
			width: 1920,
			height: 1080,
			framebuffer: {verticalSync: false}
		}, function(_) {
			#if cpp
			Window.get(0).notifyOnResize(ScaleManager.screen.resize);
			#end

			// Just loading everything is ok for small projects
			Assets.loadEverything(function() {
				Pipelines.init();
				SaveManager.loadEverything();

				Profile.changePrimary(SaveManager.getProfile(0));

				AnyInputDevice.init();
				ScreenManager.init();

				#if !kha_html5
				Window.get(0).mode = SaveManager.graphics.fullscreen ? Fullscreen : Windowed;
				#end

				ScaleManager.screen.resize(System.windowWidth(), System.windowHeight());

				#if kha_html5
				LobbyPage.handleURLJoin();
				#else
				ScreenManager.switchScreen(new MainMenuScreen());
				#end

				#if kha_html5
				Browser.window.ondrop = (ev: DragEvent) -> {
					final fr = new FileReader();

					fr.readAsText(ev.dataTransfer.files.item(0));

					fr.onload = () -> {
						// GlobalScreenSwitcher.switchScreen(new ReplayScreen(Unserializer.run(fr.result)));
					}
				}
				#else
				System.notifyOnDropFiles((path) -> {
					try {
						final contents = File.getContent(path.trim());

						// GlobalScreenSwitcher.switchScreen(new ReplayScreen(Unserializer.run(contents)));
					} catch (_) {}
				});
				#end

				lastT = Scheduler.realTime();

				System.notifyOnFrames((frames) -> {
					final now = Scheduler.realTime();
					final frameTime = now - lastT;
					lastT = now;

					accumulator += frameTime;

					if (accumulator >= FIXED_UPDATE_DELTA) {
						InputDevice.update();
						ScreenManager.updateCurrent();
					}

					accumulator %= FIXED_UPDATE_DELTA;
					alpha = accumulator / FIXED_UPDATE_DELTA;

					ScreenManager.renderCurrent(frames[0], alpha);
				});
			});
		});
	}
}

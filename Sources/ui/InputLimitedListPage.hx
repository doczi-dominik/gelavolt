package ui;

import ui.ListMenuPage.ListMenuPageOptions;
import input.IInputDevice;

@:structInit
@:build(game.Macros.buildOptionsClass(InputLimitedListPage))
class InputLimitedListPageOptions extends ListMenuPageOptions {}

class InputLimitedListPage extends ListMenuPage {
	@inject final inputDevice: IInputDevice;

	public function new(opts: InputLimitedListPageOptions) {
		super(opts);

		game.Macros.initFromOpts();
	}

	override function onShow(menu: Menu) {
		menu.pushInputDevice(inputDevice);
		super.onShow(menu);
	}

	override function popPage() {
		menu.popInputDevice();
		super.popPage();
	}
}

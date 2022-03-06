package ui;

import input.IInputDevice;

class InputLimitedListPage extends ListMenuPage {
	final inputDevice: IInputDevice;

	public function new(opts: InputLimitedListPageOptions) {
		super(opts);

		inputDevice = opts.inputDevice;
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

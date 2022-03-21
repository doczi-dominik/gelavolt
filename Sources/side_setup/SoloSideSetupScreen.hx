package side_setup;

import input.IInputDevice;
import save_data.Profile;
import input.AnyInputDevice;

class SoloSideSetupScreen extends SideSetupScreen {
	public function new(onReady: (Null<IInputDevice>, Null<IInputDevice>) -> Void) {
		devices = [new InputDeviceIcon('${Profile.primary.name}', AnyInputDevice.instance)];

		super(onReady);
	}

	override function update() {
		super.update();

		if (leftSlot != null && leftSlot.getReadyAction()) {
			onReady(leftSlot.device, null);
		}

		if (rightSlot != null && rightSlot.getReadyAction()) {
			onReady(null, rightSlot.device);
		}
	}
}

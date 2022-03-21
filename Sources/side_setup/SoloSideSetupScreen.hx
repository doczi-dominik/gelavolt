package side_setup;

import save_data.Profile;
import input.AnyInputDevice;

class SoloSideSetupScreen extends SideSetupScreen {
	public function new() {
		devices = [new InputDeviceIcon('${Profile.primary.name}', AnyInputDevice.instance)];

		super();
	}
}

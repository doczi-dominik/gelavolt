package save_data;

@:structInit
class GraphicsSettings {
	@:optional public var fullscreen = true;

	public function exportData(): GraphicsSettingsData {
		return {
			fullscreen: fullscreen
		};
	}
}

typedef GraphicsSettingsData = {
	fullscreen: Bool
};

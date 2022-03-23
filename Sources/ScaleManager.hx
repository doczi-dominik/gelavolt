class ScaleManager {
	public static inline final SCREEN_DESIGN_WIDTH = 1920;
	public static inline final SCREEN_DESIGN_HEIGHT = 1080;

	public static final screen = new ScaleManager(SCREEN_DESIGN_WIDTH, SCREEN_DESIGN_HEIGHT);

	final designWidth: Float;
	final designHeight: Float;
	final onResize: Array<Void->Void>;

	public var width(default, null): Float;
	public var height(default, null): Float;
	public var smallerScale(default, null): Float;

	public function new(designWidth: Float, designHeight: Float) {
		this.designWidth = designWidth;
		this.designHeight = designHeight;
		onResize = [];
	}

	public function resize(newWidth: Float, newHeight: Float) {
		width = newWidth;
		height = newHeight;

		smallerScale = Math.min(width / designWidth, height / designHeight);

		for (f in onResize) {
			f();
		}
	}

	public static function addOnResizeCallback(callback: Void->Void) {
		screen.onResize.push(callback);

		callback();
	}
}

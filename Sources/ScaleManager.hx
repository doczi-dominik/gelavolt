class ScaleManager {
	public static inline final DESIGN_WIDTH = 1920;
	public static inline final DESIGN_HEIGHT = 1080;

	static final onResize: Array<Void->Void> = [];

	public static var width(default, null) = 1920;
	public static var height(default, null) = 1080;

	public static var scaleX(default, null): Float;
	public static var scaleY(default, null): Float;
	public static var largerScale(default, null): Float;
	public static var smallerScale(default, null): Float;

	public static function resize(newWidth: Int, newHeight: Int) {
		width = newWidth;
		height = newHeight;

		scaleX = width / DESIGN_WIDTH;
		scaleY = height / DESIGN_HEIGHT;

		largerScale = Math.max(scaleX, scaleY);
		smallerScale = Math.min(scaleX, scaleY);

		for (k => f in onResize.keyValueIterator()) {
			f();
		}
	}

	public static function addOnResizeCallback(callback: Void->Void) {
		onResize.push(callback);

		callback();
	}
}

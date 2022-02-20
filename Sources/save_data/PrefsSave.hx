package save_data;

import kha.Color;
import game.gelos.GeloColor;

class PrefsSave {
	public var colorTints: Null<Map<GeloColor, Color>>;
	public var primaryColors: Null<Map<GeloColor, Color>>;

	public var boardBackgroundR: Null<Int>;
	public var boardBackgroundG: Null<Int>;
	public var boardBackgroundB: Null<Int>;
	public var capAtCrowns: Null<Bool>;
	public var showGroupShadow: Null<Bool>;
	public var shadowOpacity: Null<Float>;
	public var shadowHighlightOthers: Null<Bool>;
	public var shadowWillTriggerChain: Null<Bool>;

	inline function setDefaultColorTint(geloColor: GeloColor, def: Color) {
		if (colorTints[geloColor] == null)
			colorTints[geloColor] = def;
	}

	inline function setDefaultPrimary(geloColor: GeloColor, def: Color) {
		if (primaryColors[geloColor] == null)
			primaryColors[geloColor] = def;
	}

	public function new() {}

	public function setDefaults() {
		if (colorTints == null)
			colorTints = new Map<GeloColor, Color>();

		setDefaultColorTint(COLOR1, White);
		setDefaultColorTint(COLOR2, White);
		setDefaultColorTint(COLOR3, White);
		setDefaultColorTint(COLOR4, White);
		setDefaultColorTint(COLOR5, White);
		setDefaultColorTint(GARBAGE, White);

		if (primaryColors == null)
			primaryColors = new Map<GeloColor, Color>();

		setDefaultPrimary(COLOR1, Color.fromValue(0xFFFF001e));
		setDefaultPrimary(COLOR2, Color.fromValue(0xFF00FF15));
		setDefaultPrimary(COLOR3, Color.fromValue(0xFF006DFF));
		setDefaultPrimary(COLOR4, Color.fromValue(0xFFFFF300));
		setDefaultPrimary(COLOR5, Color.fromValue(0xFFC100FF));

		if (boardBackgroundR == null)
			boardBackgroundR = 64;
		if (boardBackgroundG == null)
			boardBackgroundG = 32;
		if (boardBackgroundB == null)
			boardBackgroundB = 32;
		if (capAtCrowns == null)
			capAtCrowns = true;
		if (showGroupShadow == null)
			showGroupShadow = true;
		if (shadowOpacity == null)
			shadowOpacity = 0.5;
		if (shadowHighlightOthers == null)
			shadowHighlightOthers = true;
		if (shadowWillTriggerChain == null)
			shadowWillTriggerChain = true;
	}
}

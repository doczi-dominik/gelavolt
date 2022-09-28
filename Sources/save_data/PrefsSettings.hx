package save_data;

import haxe.ds.StringMap;
import game.gelos.GeloColor;
import kha.Color;

@:nullSafety(Off) // Null safety fails on @:optional Map values
@:structInit
class PrefsSettings implements hxbit.Serializable {
	@:s @:optional public var boardBackground = Color.fromBytes(64, 32, 32);
	@:s @:optional public var menuRememberCursor = true;
	@:s @:optional public var capAtCrowns = true;
	@:s @:optional public var showGroupShadow = true;
	@:s @:optional public var shadowOpacity = 0.5;
	@:s @:optional public var shadowHighlightOthers = true;
	@:s @:optional public var shadowWillTriggerChain = true;

	@:s @:optional public var colorTints(default, null): Map<GeloColor, Color> = [
		COLOR1 => White,
		COLOR2 => White,
		COLOR3 => White,
		COLOR4 => White,
		COLOR5 => White,
		EMPTY => White,
		GARBAGE => White,
	];

	@:s @:optional public var primaryColors(default, null): Map<GeloColor, Color> = [
		COLOR1 => Color.fromValue(0xFFFF001e),
		COLOR2 => Color.fromValue(0xFF00FF15),
		COLOR3 => Color.fromValue(0xFF006DFF),
		COLOR4 => Color.fromValue(0xFFFFF300),
		COLOR5 => Color.fromValue(0xFFC100FF),
		EMPTY => Transparent,
		GARBAGE => Transparent,
	];
}

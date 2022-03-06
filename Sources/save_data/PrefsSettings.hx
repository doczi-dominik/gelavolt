package save_data;

import game.gelos.GeloColor;
import kha.Color;

@:structInit
class PrefsSettings {
	@:optional public final colorTints: GeloColorSettings = {
		color1: White,
		color2: White,
		color3: White,
		color4: White,
		color5: White,
		empty: White,
		garbage: White
	};

	@:optional public final primaryColors: GeloColorSettings = {
		color1: Color.fromValue(0xFFFF001e),
		color2: Color.fromValue(0xFF00FF15),
		color3: Color.fromValue(0xFF006DFF),
		color4: Color.fromValue(0xFFFFF300),
		color5: Color.fromValue(0xFFc100FF),
		empty: Transparent,
		garbage: Transparent
	};

	@:optional public var boardBackground = Color.fromBytes(64, 32, 32);
	@:optional public var capAtCrowns = true;
	@:optional public var showGroupShadow = true;
	@:optional public var shadowOpacity = 0.5;
	@:optional public var shadowHighlightOthers = true;
	@:optional public var shadowWillTriggerChain = true;

	public function exportData(): PrefsSettingsData {
		return {
			colorTints: {
				color1: colorTints.color1,
				color2: colorTints.color2,
				color3: colorTints.color3,
				color4: colorTints.color4,
				color5: colorTints.color5,
				empty: colorTints.empty,
				garbage: colorTints.garbage,
			},
			primaryColors: {
				color1: primaryColors.color1,
				color2: primaryColors.color2,
				color3: primaryColors.color3,
				color4: primaryColors.color4,
				color5: primaryColors.color5,
				empty: primaryColors.empty,
				garbage: primaryColors.garbage,
			},
			boardBackground: boardBackground,
			capAtCrowns: capAtCrowns,
			showGroupShadow: showGroupShadow,
			shadowOpacity: shadowOpacity,
			shadowHighlightOthers: shadowHighlightOthers,
			shadowWillTriggerChain: shadowWillTriggerChain
		};
	}

	public function getColorTint(color: GeloColor) {
		return switch (color) {
			case COLOR1: colorTints.color1;
			case COLOR2: colorTints.color2;
			case COLOR3: colorTints.color3;
			case COLOR4: colorTints.color4;
			case COLOR5: colorTints.color5;
			case EMPTY: colorTints.empty;
			case GARBAGE: colorTints.garbage;
		}
	}

	public function getPrimaryColor(color: GeloColor) {
		return switch (color) {
			case COLOR1: primaryColors.color1;
			case COLOR2: primaryColors.color2;
			case COLOR3: primaryColors.color3;
			case COLOR4: primaryColors.color4;
			case COLOR5: primaryColors.color5;
			case EMPTY: primaryColors.empty;
			case GARBAGE: primaryColors.garbage;
		}
	}
}

typedef PrefsSettingsData = {
	colorTints: GeloColorSettings,
	primaryColors: GeloColorSettings,
	boardBackground: Color,
	capAtCrowns: Bool,
	showGroupShadow: Bool,
	shadowOpacity: Float,
	shadowHighlightOthers: Bool,
	shadowWillTriggerChain: Bool
};

private typedef GeloColorSettings = {
	color1: Color,
	color2: Color,
	color3: Color,
	color4: Color,
	color5: Color,
	empty: Color,
	garbage: Color,
};

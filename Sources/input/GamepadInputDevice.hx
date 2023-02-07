package input;

import main.ScaleManager;
import haxe.ds.ReadOnlyArray;
import utils.Utils;
import game.actions.ActionData.ACTION_DATA;
import input.AxisSpriteCoordinates.AXIS_SPRITE_COORDINATES;
import input.ButtonSpriteCoordinates.BUTTON_SPRITE_COORDINATES;
import haxe.ds.HashMap;
import kha.Assets;
import utils.Geometry;
import kha.graphics2.Graphics;
import ui.ControlHint;
import game.actions.Action;
import save_data.InputSettings;
import kha.input.Gamepad;

using Safety;

class GamepadInputDevice extends InputDevice {
	static inline final SEPARATOR = " / ";

	public static function renderButton(g: Graphics, x: Float, y: Float, scale: Float, sprite: Geometry) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}

	final id: Int;
	final gamepad: Gamepad;

	var separatorWidth = 0.0;

	var buttonsToActions: Null<Map<Int, Null<Array<Action>>>>;
	var axesToActions: Null<HashMap<AxisMapping, Null<Array<Action>>>>;
	var axesCache: Null<Array<Int>>;
	var latestButtonRebindFunction: Null<(Int, Float) -> Void>;
	var latestAxisRebindFunction: Null<(Int, Float) -> Void>;

	public function new(inputSettings: InputSettings, gamepadID: Int) {
		id = gamepadID;
		gamepad = Gamepad.get(gamepadID);

		super(GAMEPAD, inputSettings);
	}

	function buttonListener(button: Int, value: Float) {
		if (buttonsToActions == null) {
			return;
		}

		final bta = buttonsToActions.sure();

		if (value != 0) {
			AnyInputDevice.lastDeviceID = id;
		}

		final actions = bta[button].sure();

		if (value == 0) {
			upListener(actions);
		} else {
			downListener(actions);
		}
	}

	function downListener(actions: Array<Action>) {
		if (counters == null) {
			return;
		}

		for (action in actions) {
			counters.sure()[action] = 0;
		}
	}

	function upListener(actions: Array<Action>) {
		if (counters == null) {
			return;
		}

		for (action in actions) {
			counters.sure().remove(action);
		}
	}

	function axisListener(axis: Int, value: Float) {
		if (axesToActions == null || axesCache == null) {
			return;
		}

		final ata = axesToActions.sure();
		final ac = axesCache.sure();

		for (k => v in ata) {
			if (v == null) {
				continue;
			}

			final safeV = v.sure();
			// Easy matching using multiplication
			// -1 * -1 => 1
			// 1 * 1 => 1
			// If the direction and value signs match, the result is positive
			if (k.axis == axis && k.direction != null && k.direction * value >= 0) {
				var somethingChanged = false;

				if (Math.abs(value) > inputSettings.deadzone) {
					if (!ac.contains(axis)) {
						AnyInputDevice.lastDeviceID = id;

						downListener(safeV);

						ac.push(axis);
						somethingChanged = true;
					}
				} else {
					if (ac.contains(axis)) {
						upListener(safeV);

						ac.remove(axis);
						somethingChanged = true;
					}
				}

				if (somethingChanged) {
					// Clear actions assigned to the inverse direction. With
					// properly configured deadzone, this prevents stick "rebound"
					// and drifting.
					final oppositeMapping: AxisMapping = {axis: axis, direction: k.direction.sure() * -1};
					final oppositeAction = ata[oppositeMapping];

					if (oppositeAction != null) {
						upListener(oppositeAction);
					}
				}
			}
		}
	}

	function buttonRebindListener(action: Action, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputSettings.mappings[action];

		if (original == null) {
			return;
		}

		inputSettings.mappings[action] = ({
			keyboardInput: original.keyboardInput,
			gamepadButton: button,
			gamepadAxis: original.gamepadAxis
		} : InputMapping);

		finishRebind();
	}

	function axisRebindListener(action: Action, axis: Int, value: Float) {
		if (value <= inputSettings.deadzone && value >= -inputSettings.deadzone)
			return;

		final original = inputSettings.mappings[action];

		if (original == null) {
			return;
		}

		inputSettings.mappings[action] = ({
			keyboardInput: original.keyboardInput,
			gamepadButton: original.gamepadButton,
			gamepadAxis: {axis: axis, direction: (value > 0) ? 1 : -1}
		} : InputMapping);

		finishRebind();
	}

	override function buildActions() {
		counters = [];
		actions = [];
		buttonsToActions = [];
		axesToActions = new HashMap();
		axesCache = [];

		final acs = actions.sure();
		final bta = buttonsToActions.sure();
		final ata = axesToActions.sure();

		for (action in ACTION_DATA.keys()) {
			final mapping = inputSettings.mappings[action];

			if (mapping == null) {
				continue;
			}

			final buttonMapping = mapping.gamepadButton;

			if (buttonMapping != null) {
				if (bta[buttonMapping] == null)
					bta[buttonMapping] = [];

				bta[buttonMapping].sure().push(action);
			}

			final axisMapping = mapping.gamepadAxis;

			if (!axisMapping.isNull()) {
				if (ata[axisMapping] == null)
					ata[axisMapping] = [];

				ata[axisMapping].sure().push(action);
			}

			switch (ACTION_DATA[action].sure().inputType) {
				case HOLD:
					acs[action] = holdActionHandler;
				case PRESS:
					acs[action] = pressActionHandler;
				case REPEAT:
					acs[action] = repeatActionHandler;
			}
		}
	}

	override function addListeners() {
		try {
			gamepad.notify(axisListener, buttonListener);
		}
	}

	override function removeListeners() {
		try {
			gamepad.remove(axisListener, buttonListener);
		}
	}

	override function removeRebindListeners() {
		try {
			gamepad.remove(latestAxisRebindFunction, latestButtonRebindFunction);
		}
	}

	override function unbind(action: Action) {
		final old = inputSettings.mappings[action];

		if (old == null) {
			return;
		}

		inputSettings.mappings[action] = ({
			keyboardInput: old.keyboardInput,
			gamepadButton: null,
			gamepadAxis: {
				axis: null,
				direction: null
			}
		} : InputMapping);

		super.unbind(action);
	}

	override function bindDefault(action: Action) {
		final def = InputSettings.MAPPINGS_DEFAULTS[action];
		final old = inputSettings.mappings[action];

		if (def == null || old == null) {
			return;
		}

		inputSettings.mappings[action] = ({
			keyboardInput: old.keyboardInput,
			gamepadButton: def.gamepadButton,
			gamepadAxis: def.gamepadAxis
		} : InputMapping);

		super.bindDefault(action);
	}

	override function rebind(action: Action) {
		super.rebind(action);

		latestAxisRebindFunction = axisRebindListener.bind(action);
		latestButtonRebindFunction = buttonRebindListener.bind(action);
		latestRebindAction = action;

		try {
			gamepad.notify(latestAxisRebindFunction, latestButtonRebindFunction);
		}
	}

	override function renderBinding(g: Graphics, x: Float, y: Float, scale: Float, action: Action) {
		if (ACTION_DATA[action] == null || inputSettings.mappings[action] == null) {
			return;
		}

		final title = ACTION_DATA[action].sure().title;
		final mapping = inputSettings.mappings[action].sure();

		if (action == latestRebindAction && isRebinding) {
			g.drawString('Press any button / stick for [ $title ]', x, y);

			return;
		}

		if (mapping.gamepadButton == null && mapping.gamepadAxis.isNull()) {
			g.drawString('$title: [ UNBOUND ]', x, y);
			return;
		}

		final fontHeight = g.font.height(g.fontSize);
		final str = '$title: ';
		final strW = g.font.width(g.fontSize, str);

		g.drawString(str, x, y);
		x += strW;

		g.color = White;

		final buttonMapping = mapping.gamepadButton;

		if (buttonMapping != null) {
			final buttonSpr = BUTTON_SPRITE_COORDINATES[inputSettings.gamepadBrand].sure()[buttonMapping];

			if (buttonSpr != null) {
				renderButton(g, x, y, fontHeight / buttonSpr.height, buttonSpr);
				x += buttonSpr.width * scale;
			} else {
				final str = 'BUTTON$buttonMapping';
				g.drawString(str, x, y);
				x += g.font.width(g.fontSize, str);
			}
		}

		final axisMapping = mapping.gamepadAxis;
		final hashCode = mapping.gamepadAxis.hashCode();

		if (!axisMapping.isNull() && hashCode != null) {
			final axisSpr = AXIS_SPRITE_COORDINATES[inputSettings.gamepadBrand].sure()[hashCode];

			if (axisSpr != null) {
				renderButton(g, x, y, fontHeight / axisSpr.height, axisSpr);
			} else {
				g.drawString('AXIS${axisMapping.axis}', x, y);
			}
		}
	}

	override function renderControls(g: Graphics, x: Float, width: Float, padding: Float, controls: ReadOnlyArray<ControlHint>) {
		final fontHeight = g.font.height(g.fontSize);
		final y = ScaleManager.screen.height - padding - fontHeight;
		final paddedScreenWidth = width - padding * 2;

		var totalWidth = 0.0;

		for (d in controls) {
			for (action in d.actions) {
				final mapping = inputSettings.mappings[action];

				if (mapping == null) {
					continue;
				}

				final button = mapping.gamepadButton;
				final axis = mapping.gamepadAxis;

				final buttonSpr = inputSettings.getButtonSprite(action);

				if (buttonSpr != null) {
					totalWidth += buttonSpr.width * (fontHeight / buttonSpr.height) * 1.25;
				}

				if (!axis.isNull()) {
					final axisSpr = inputSettings.getAxisSprite(action);

					if (axisSpr != null) {
						totalWidth += axisSpr.width * (fontHeight / axisSpr.height) * 1.25;
					} else {
						totalWidth += g.font.width(g.fontSize, 'AXIS${axis.axis}') * 1.25;
					}
				}
			}

			totalWidth += g.font.width(g.fontSize, ' : ${d.description}    ');
		}

		final scrollX = getScrollX(totalWidth, paddedScreenWidth);

		for (d in controls) {
			var str = "";

			for (action in d.actions) {
				final mapping = inputSettings.mappings[action];

				if (mapping == null) {
					continue;
				}

				final axis = mapping.gamepadAxis;

				final buttonSpr = inputSettings.getButtonSprite(action);

				if (buttonSpr != null) {
					final buttonScale = fontHeight / buttonSpr.height;

					renderButton(g, x - scrollX, y, buttonScale, buttonSpr);
					x += buttonSpr.width * buttonScale * 1.25;
				}

				if (!axis.isNull()) {
					final axisSpr = inputSettings.getAxisSprite(action);

					if (axisSpr != null) {
						final axisScale = fontHeight / axisSpr.height;

						renderButton(g, x - scrollX, y, axisScale, axisSpr);
						x += axisSpr.width * axisScale * 1.25;
					} else {
						final str = 'AXIS${axis.axis}';
						g.drawString(str, x - scrollX, y);
						x += g.font.width(g.fontSize, str) * 1.25;
					}
				}
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';

			final strWidth = g.font.width(g.fontSize, str);

			Utils.shadowDrawString(g, 3, Black, White, str, x - scrollX, y);

			x += strWidth;
		}
	}
}

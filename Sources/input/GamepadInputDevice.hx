package input;

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

class GamepadInputDevice extends InputDevice {
	static inline final SEPARATOR = " / ";

	public static function renderButton(g: Graphics, x: Float, y: Float, scale: Float, sprite: Geometry) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}

	final id: Int;
	final gamepad: Gamepad;

	var separatorWidth: Float;

	var buttonsToActions: Map<Int, Null<Array<Action>>>;
	var axesToActions: HashMap<AxisMapping, Null<Array<Action>>>;
	var axesCache: Array<Int>;
	var latestButtonRebindFunction: (Int, Float) -> Void;
	var latestAxisRebindFunction: (Int, Float) -> Void;

	public function new(inputSettings: InputSettings, gamepadID: Int) {
		id = gamepadID;
		gamepad = Gamepad.get(gamepadID);

		super(GAMEPAD, inputSettings);
	}

	function buttonListener(button: Int, value: Float) {
		if (value != 0)
			AnyInputDevice.lastDeviceID = id;

		if (!buttonsToActions.exists(button))
			return;

		final actions = buttonsToActions[button];

		if (value == 0) {
			upListener(actions);
		} else {
			downListener(actions);
		}
	}

	function downListener(actions: Array<Action>) {
		for (action in actions) {
			counters[action] = 0;
		}
	}

	function upListener(actions: Array<Action>) {
		for (action in actions) {
			counters.remove(action);
		}
	}

	function axisListener(axis: Int, value: Float) {
		for (k => v in axesToActions.keyValueIterator()) {
			// Easy matching using multiplication
			// -1 * -1 => 1
			// 1 * 1 => 1
			// If the direction and value signs match, the result is positive
			if (k.axis == axis && k.direction * value >= 0) {
				var somethingChanged = false;

				if (Math.abs(value) > inputSettings.deadzone) {
					if (!axesCache.contains(axis)) {
						AnyInputDevice.lastDeviceID = id;

						downListener(v);

						axesCache.push(axis);
						somethingChanged = true;
					}
				} else {
					if (axesCache.contains(axis)) {
						upListener(v);

						axesCache.remove(axis);
						somethingChanged = true;
					}
				}

				if (somethingChanged) {
					// Clear actions assigned to the inverse direction. With
					// properly configured deadzone, this prevents stick "rebound"
					// and drifting.
					final oppositeMapping: AxisMapping = {axis: axis, direction: k.direction * -1};

					if (axesToActions.exists(oppositeMapping)) {
						upListener(axesToActions[oppositeMapping]);
					}
				}
			}
		}
	}

	function buttonRebindListener(action: Action, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputSettings.mappings[action];

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

		for (action in ACTION_DATA.keys()) {
			final mapping = inputSettings.mappings[action];

			final buttonMapping = mapping.gamepadButton;

			if (buttonMapping != null) {
				if (buttonsToActions[buttonMapping] == null)
					buttonsToActions[buttonMapping] = [];

				buttonsToActions[buttonMapping].push(action);
			}

			final axisMapping = mapping.gamepadAxis;

			if (!axisMapping.isNull()) {
				if (axesToActions[axisMapping] == null)
					axesToActions[axisMapping] = [];

				axesToActions[axisMapping].push(action);
			}

			switch (ACTION_DATA[action].inputType) {
				case HOLD:
					actions[action] = holdActionHandler;
				case PRESS:
					actions[action] = pressActionHandler;
				case REPEAT:
					actions[action] = repeatActionHandler;
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
		final title = ACTION_DATA[action].title;

		if (action == latestRebindAction && isRebinding) {
			g.drawString('Press any button / stick for [ $title ]', x, y);

			return;
		}

		final mapping = inputSettings.mappings[action];

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
			final buttonSpr = BUTTON_SPRITE_COORDINATES[inputSettings.gamepadBrand][buttonMapping];

			renderButton(g, x, y, fontHeight / buttonSpr.height, buttonSpr);
			x += buttonSpr.width * scale;
		}

		final axisMapping = mapping.gamepadAxis;

		if (!axisMapping.isNull()) {
			final axisSpr = AXIS_SPRITE_COORDINATES[inputSettings.gamepadBrand][mapping.gamepadAxis.hashCode()];

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

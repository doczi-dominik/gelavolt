package input;

import haxe.ds.HashMap;
import kha.Assets;
import game.actions.ActionTitles.ACTION_TITLES;
import utils.Geometry;
import input.GamepadSpriteCoordinates.GAMEPAD_SPRITE_COORDINATES;
import kha.graphics2.Graphics;
import ui.ControlDisplay;
import game.actions.ActionInputTypes.ACTION_INPUT_TYPES;
import game.actions.Action;
import save_data.InputSettings;
import kha.input.Gamepad;

class GamepadInputDevice extends InputDevice {
	public static function renderButton(g: Graphics, x: Float, y: Float, scale: Float, sprite: Geometry) {
		final w = sprite.width;
		final h = sprite.height;

		g.drawScaledSubImage(Assets.images.Buttons, sprite.x, sprite.y, w, h, x, y, w * scale, h * scale);
	}

	final id: Int;
	final gamepad: Gamepad;

	var controlsFontHeight: Float;
	var bindingsFontHeight: Float;

	var buttonsToActions: Map<Int, Null<Array<Action>>>;
	var axesToActions: HashMap<AxisMapping, Null<Array<Action>>>;
	var latestRebindFunction: (Int, Float) -> Void;

	public function new(inputSettings: InputSettings, gamepadID: Int) {
		id = gamepadID;
		gamepad = Gamepad.get(gamepadID);

		super(GAMEPAD, inputSettings);
	}

	function buttonListener(button: Int, value: Float) {
		if (value != 0)
			AnyInputDevice.lastGamepadID = id;

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
			if (counters.exists(action))
				continue;

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
				if (Math.abs(value) > inputSettings.deadzone) {
					downListener(v);
				} else {
					upListener(v);
				}

				// Clear actions assigned to the inverse direction. With
				// properly configured deadzone, this prevents stick "rebound"
				// and drifting.
				final oppositeMapping: AxisMapping = {axis: axis, direction: k.direction * -1};
				upListener(axesToActions[oppositeMapping]);

				return;
			}
		}
	}

	function rebindListener(action: Action, button: Int, value: Float) {
		if (value == 0)
			return;

		final original = inputSettings.getMapping(action);

		inputSettings.setMapping(action, {
			keyboardInput: original.keyboardInput,
			gamepadButton: button,
			gamepadAxis: original.gamepadAxis
		});

		finishRebind();
	}

	override function buildActions() {
		actions = [];
		buttonsToActions = [];
		axesToActions = new HashMap();

		for (action in Type.allEnums(Action)) {
			final mapping = inputSettings.getMapping(action);

			final buttonInput = mapping.gamepadButton;

			if (buttonsToActions[buttonInput] == null)
				buttonsToActions[buttonInput] = [];

			buttonsToActions[buttonInput].push(action);

			final axisMapping = mapping.gamepadAxis;

			if (axisMapping != null) {
				if (axesToActions[axisMapping] == null)
					axesToActions[axisMapping] = [];

				axesToActions[axisMapping].push(action);
			}

			switch (ACTION_INPUT_TYPES[action]) {
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
			gamepad.remove(null, buttonListener);
		}
	}

	override function removeRebindListeners() {
		try {
			gamepad.remove(null, latestRebindFunction);
		}
	}

	override function rebind(action: Action) {
		super.rebind(action);

		latestRebindFunction = rebindListener.bind(action);
		latestRebindAction = action;

		try {
			gamepad.notify(null, latestRebindFunction);
		}
	}

	override function onResize() {
		super.onResize();

		controlsFontHeight = font.height(controlsFontSize);
		bindingsFontHeight = font.height(bindingsFontSize);
	}

	override function renderBinding(g: Graphics, x: Float, y: Float, action: Action) {
		super.renderBinding(g, x, y, action);

		final title = ACTION_TITLES[action];

		if (action == latestRebindAction && isRebinding) {
			g.drawString('Press any button for [ $title ]', x, y);

			return;
		}

		final str = '$title: ';
		final strW = font.width(bindingsFontSize, str);
		final spr = GAMEPAD_SPRITE_COORDINATES[inputSettings.getMapping(action).gamepadButton];

		g.drawString(str, x, y);

		g.color = White;

		renderButton(g, x + strW, y, bindingsFontHeight / spr.height, spr);
	}

	override function renderControls(g: Graphics, x: Float, y: Float, controls: Array<ControlDisplay>) {
		super.renderControls(g, x, y, controls);

		for (d in controls) {
			var str = "";

			for (action in d.actions) {
				final spr = GAMEPAD_SPRITE_COORDINATES[inputSettings.getMapping(action).gamepadButton];

				renderButton(g, x, y, controlsFontHeight / spr.height, spr);

				x += spr.width * ScaleManager.smallerScale;
			}

			str = str.substring(0, str.length - 1);

			// Hackerman but it beats having to calculate with scaling
			str += ' : ${d.description}    ';

			final strWidth = font.width(controlsFontSize, str);

			g.drawString(str, x, y);

			x += strWidth;
		}
	}
}

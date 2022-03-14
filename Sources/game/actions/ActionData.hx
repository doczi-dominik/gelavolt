package game.actions;

final ACTION_DATA: Map<Action, ActionDataEntry> = [
	PAUSE => {title: "Pause", description: ["Pause/Unpause The Game"], inputType: PRESS},
	MENU_LEFT => {title: "Left", description: ["Move Left In Menus"], inputType: REPEAT},
	MENU_RIGHT => {title: "Right", description: ["Move Right In Menus"], inputType: REPEAT},
	MENU_DOWN => {title: "Down", description: ["Move Down In Menus"], inputType: REPEAT},
	MENU_UP => {title: "Up", description: ["Move Up In Menus"], inputType: REPEAT},
	BACK => {title: "Back", description: ["Go Back One Submenu"], inputType: PRESS},
	CONFIRM => {title: "Confirm", description: ["Activate A Menu Entry"], inputType: PRESS},
	SHIFT_LEFT => {title: "Shift Left", description: ["Shift The Gelo Group", "To The Left"], inputType: HOLD},
	SHIFT_RIGHT => {title: "Shift Right", description: ["Shift The Gelo Group", "To The Right"], inputType: HOLD},
	SOFT_DROP => {title: "Soft Drop", description: ["Hold To Make The Gelo Group", "Fall Faster"], inputType: HOLD},
	HARD_DROP => {
		title: "Hard Drop",
		description: [
			"Press To Make The Gelo Group",
			"Instantly Fall To The Bottom",
			"(Only When Enabled In The Ruleset)"
		],
		inputType: PRESS
	},
	ROTATE_LEFT => {title: "Rotate Left", description: ["Rotate The Gelo Group Counterclockwise"], inputType: PRESS},
	ROTATE_RIGHT => {title: "Rotate Right", description: ["Rotate The Gelo Group Clockwise"], inputType: PRESS},
	TOGGLE_EDIT_MODE => {title: "Toggle Edit Mode", description: ["Toggle Between Play Mode And Edit Mode"], inputType: PRESS},
	EDIT_LEFT => {title: "Move Cursor Left", description: ["Move The Editing Cursor Left"], inputType: REPEAT},
	EDIT_RIGHT => {title: "Move Cursor Right", description: ["Move The Editing Cursor Right"], inputType: REPEAT},
	EDIT_DOWN => {title: "Move Cursor Down", description: ["Move The Editing Cursor Down"], inputType: REPEAT},
	EDIT_UP => {title: "Move Cursor Up", description: ["Move The Editing Cursor Up"], inputType: REPEAT},
	EDIT_SET => {title: "Place Gelo / Marker", description: ["Set The Selected Gelo", "Or Marker At The Cursor"], inputType: PRESS},
	EDIT_CLEAR => {title: "Clear Gelo / Marker", description: ["Clear The Gelo or Marker At The", "Cursor's Location"], inputType: PRESS},
	PREVIOUS_STEP => {title: "Previous Step", description: ["Select The Previous Chain Step"], inputType: REPEAT},
	NEXT_STEP => {title: "Next Step", description: ["Select The Next Chain Step"], inputType: REPEAT},
	PREVIOUS_COLOR => {title: "Previous Color / Marker", description: ["Cycle Backwards To The Gelo / Marker You", "Want To Place"], inputType: REPEAT},
	NEXT_COLOR => {title: "Next Color / Marker", description: ["Cycle Forwards To The Gelo / Marker You Want to Place"], inputType: REPEAT},
	PREVIOUS_GROUP => {title: "Undo", description: ["Undo The Last Gelo Group Placement"], inputType: REPEAT},
	NEXT_GROUP => {title: "Draw Next Group", description: ["Discard The Current Gelo Group", "And Draw The Next One From", "The Queue"], inputType: REPEAT},
	TOGGLE_MARKERS => {title: "Toggle Gelos / Markers", description: ["Alternate Between Editing Gelos And", "Editing Markers"], inputType: PRESS},
];

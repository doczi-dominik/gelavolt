package game.actions;

final ACTION_DATA: Map<Action, ActionDataEntry> = [
	PAUSE => {
		title: "Pause",
		description: ["Pause/Unpause The Game"],
		inputType: PRESS,
		isUnbindable: false
	},
	MENU_LEFT => {
		title: "Left",
		description: ["Move Left In Menus"],
		inputType: REPEAT,
		isUnbindable: false
	},
	MENU_RIGHT => {
		title: "Right",
		description: ["Move Right In Menus"],
		inputType: REPEAT,
		isUnbindable: false
	},
	MENU_DOWN => {
		title: "Down",
		description: ["Move Down In Menus"],
		inputType: REPEAT,
		isUnbindable: false
	},
	MENU_UP => {
		title: "Up",
		description: ["Move Up In Menus"],
		inputType: REPEAT,
		isUnbindable: false
	},
	BACK => {
		title: "Back",
		description: ["Go Back One Submenu"],
		inputType: PRESS,
		isUnbindable: false
	},
	CONFIRM => {
		title: "Confirm",
		description: ["Activate A Menu Entry"],
		inputType: PRESS,
		isUnbindable: false
	},
	SHIFT_LEFT => {
		title: "Shift Left",
		description: ["Shift The Gelo Group", "To The Left"],
		inputType: HOLD,
		isUnbindable: false
	},
	SHIFT_RIGHT => {
		title: "Shift Right",
		description: ["Shift The Gelo Group", "To The Right"],
		inputType: HOLD,
		isUnbindable: false
	},
	SOFT_DROP => {
		title: "Soft Drop",
		description: ["Hold To Make The Gelo Group", "Fall Faster"],
		inputType: HOLD,
		isUnbindable: false
	},
	HARD_DROP => {
		title: "Hard Drop",
		description: [
			"Press To Make The Gelo Group",
			"Instantly Fall To The Bottom",
			"(Only When Enabled In The Ruleset)"
		],
		inputType: PRESS,
		isUnbindable: false
	},
	ROTATE_LEFT => {
		title: "Rotate Left",
		description: ["Rotate The Gelo Group Counterclockwise"],
		inputType: PRESS,
		isUnbindable: false
	},
	ROTATE_RIGHT => {
		title: "Rotate Right",
		description: ["Rotate The Gelo Group Clockwise"],
		inputType: PRESS,
		isUnbindable: false
	},
	TOGGLE_EDIT_MODE => {
		title: "Toggle Edit Mode",
		description: ["Toggle Between Play Mode And Edit Mode"],
		inputType: PRESS,
		isUnbindable: true
	},
	EDIT_LEFT => {
		title: "Move Cursor Left",
		description: ["Move The Editing Cursor Left"],
		inputType: REPEAT,
		isUnbindable: false
	},
	EDIT_RIGHT => {
		title: "Move Cursor Right",
		description: ["Move The Editing Cursor Right"],
		inputType: REPEAT,
		isUnbindable: false
	},
	EDIT_DOWN => {
		title: "Move Cursor Down",
		description: ["Move The Editing Cursor Down"],
		inputType: REPEAT,
		isUnbindable: false
	},
	EDIT_UP => {
		title: "Move Cursor Up",
		description: ["Move The Editing Cursor Up"],
		inputType: REPEAT,
		isUnbindable: false
	},
	EDIT_SET => {
		title: "Place Gelo / Marker",
		description: ["Set The Selected Gelo", "Or Marker At The Cursor"],
		inputType: PRESS,
		isUnbindable: false
	},
	EDIT_CLEAR => {
		title: "Clear Gelo / Marker",
		description: ["Clear The Gelo or Marker At The", "Cursor's Location"],
		inputType: PRESS,
		isUnbindable: false
	},
	PREVIOUS_STEP => {
		title: "Previous Step",
		description: ["Select The Previous Chain Step"],
		inputType: REPEAT,
		isUnbindable: false
	},
	NEXT_STEP => {
		title: "Next Step",
		description: ["Select The Next Chain Step"],
		inputType: REPEAT,
		isUnbindable: false
	},
	PREVIOUS_COLOR => {
		title: "Previous Color / Marker",
		description: ["Cycle Backwards To The Gelo / Marker You", "Want To Place"],
		inputType: REPEAT,
		isUnbindable: false
	},
	NEXT_COLOR => {
		title: "Next Color / Marker",
		description: ["Cycle Forwards To The Gelo / Marker You Want to Place"],
		inputType: REPEAT,
		isUnbindable: false
	},
	PREVIOUS_GROUP => {
		title: "Undo",
		description: ["Undo The Last Gelo Group Placement"],
		inputType: REPEAT,
		isUnbindable: true
	},
	NEXT_GROUP => {
		title: "Redo",
		description: [
			"Redo The Last Undone Placement Or Get",
			"The Next Gelo Group From",
			"The Queue If There Is Nothing",
			"To Undo"
		],
		inputType: REPEAT,
		isUnbindable: true
	},
	TOGGLE_MARKERS => {
		title: "Toggle Gelos / Markers",
		description: ["Alternate Between Editing Gelos And", "Editing Markers"],
		inputType: PRESS,
		isUnbindable: true
	},
	QUICK_RESTART => {
		title: "Quick Restart",
		description: [
			"Clear The Field And Reset According",
			"To The 'Clear On X Mode' Settings",
			"(Endless/Training Mode ONLY)"
		],
		inputType: REPEAT,
		isUnbindable: true
	},
	SAVE_STATE => {
		title: "Save State",
		description: ["Create A 'Rewind Point' That", "You Can Return To Using", "Load State"],
		inputType: PRESS,
		isUnbindable: true,
	},
	LOAD_STATE => {
		title: "Load State",
		description: ["Return To The 'Rewind Point'", "Previously Saved Using", "Save State"],
		inputType: PRESS,
		isUnbindable: true
	}
];

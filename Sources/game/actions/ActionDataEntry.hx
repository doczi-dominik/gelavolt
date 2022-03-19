package game.actions;

import input.InputType;

@:structInit
class ActionDataEntry {
	public final title: String;
	public final description: Array<String>;
	public final inputType: InputType;
	public final isUnbindable: Bool;
}

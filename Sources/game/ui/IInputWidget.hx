package game.ui;

import game.actions.Action;
import ui.IListWidget;

interface IInputWidget extends IListWidget {
	public final action: Action;

	public var isRebinding: Bool;
}

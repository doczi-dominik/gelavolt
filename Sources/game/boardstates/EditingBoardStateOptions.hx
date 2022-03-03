package game.boardstates;

import input.IInputDevice;
import game.fields.Field;
import save_data.PrefsSettings;
import game.simulation.ChainSimulator;
import game.ChainCounter;
import game.fields.Field;
import game.geometries.BoardGeometries;

@:structInit
class EditingBoardStateOptions {
	public final geometries: BoardGeometries;
	public final inputDevice: IInputDevice;
	public final field: Field;
	public final chainSim: ChainSimulator;
	public final chainCounter: ChainCounter;
	public final prefsSettings: PrefsSettings;
}

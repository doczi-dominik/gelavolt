package game.boardstates;

import game.fields.Field;
import save_data.PrefsSave;
import game.simulation.ChainSimulator;
import game.ChainCounter;
import game.fields.Field;
import game.geometries.BoardGeometries;
import input.IInputDeviceManager;

@:structInit
class EditingBoardStateOptions {
	public final geometries: BoardGeometries;
	public final inputManager: IInputDeviceManager;
	public final field: Field;
	public final chainSim: ChainSimulator;
	public final chainCounter: ChainCounter;
	public final prefsSave: PrefsSave;
}

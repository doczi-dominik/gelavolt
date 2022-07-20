package game.gamestatebuilders;

interface IGameStateBuilderOptions extends hxbit.Serializable {
	public function getType(): GameStateBuilderType;
}

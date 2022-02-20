package save_data;

class TrainingSave {
	public var clearOnXMode: Null<ClearOnXMode>;
	public var autoClear: Null<Bool>;
	public var autoAttack: Null<Bool>;
	public var minAttackTime: Null<Int>;
	public var maxAttackTime: Null<Int>;
	public var minAttackChain: Null<Int>;
	public var maxAttackChain: Null<Int>;
	public var minAttackGroupDiff: Null<Int>;
	public var maxAttackGroupDiff: Null<Int>;
	public var minAttackColors: Null<Int>;
	public var maxAttackColors: Null<Int>;

	public function new() {}

	public function setDefaults() {
		if (clearOnXMode == null)
			clearOnXMode = RESTART;
		if (autoClear == null)
			autoClear = true;
		if (autoAttack == null)
			autoAttack = false;
		if (minAttackTime == null)
			minAttackTime = 10;
		if (maxAttackTime == null)
			maxAttackTime = 10;
		if (minAttackChain == null)
			minAttackChain = 3;
		if (maxAttackChain == null)
			maxAttackChain = 3;
		if (minAttackGroupDiff == null)
			minAttackGroupDiff = 0;
		if (maxAttackGroupDiff == null)
			maxAttackGroupDiff = 0;
		if (minAttackColors == null)
			minAttackColors = 1;
		if (maxAttackColors == null)
			maxAttackColors = 1;
	}
}

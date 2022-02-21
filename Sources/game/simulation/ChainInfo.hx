package game.simulation;

class ChainInfo {
	public final links: Array<LinkInfo>;

	public final totalGarbage: Int;
	public final chainLength: Int;
	public final endsInAllClear: Bool;

	public function new(links: Array<LinkInfo>, endsInAllClear: Bool) {
		this.links = links;

		if (links.length == 0) {
			totalGarbage = 0;
			chainLength = 0;
			this.endsInAllClear = false;

			return;
		}

		final lastLink = links[links.length - 1];

		totalGarbage = lastLink.accumulatedGarbage;
		chainLength = lastLink.chain;

		this.endsInAllClear = endsInAllClear;
	}
}

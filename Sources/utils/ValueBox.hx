package utils;

@:structInit
private class ValueBoxImpl<T> {
	public var v: T;
}

@:forward(v)
abstract ValueBox<T>(ValueBoxImpl<T>) {
	inline public function new(v: T) {
		this = {
			v: v
		};
	}

	@:from
	public static function fromValue<T>(v: T): ValueBox<T> {
		return new ValueBox<T>(v);
	}

	@:to
	public function toValue() {
		return this.v;
	}
}

package game;

import game.gamestatebuilders.GameStateBuilderType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Macros {
	public static macro function buildOptionsClass(classes: Array<Expr>): Array<Field> {
		final pos = Context.currentPos();
		final fields = Context.getBuildFields();

		for (c in classes) {
			var classType: ClassType;

			switch (c.expr) {
				case EConst(CIdent(className)):
					switch (Context.getType(className)) {
						case TInst(t, _):
							classType = t.get();

						default:
							Context.fatalError('The provided identifier "$className" is not a class', pos);
					}

				default:
					Context.fatalError('The provided expression "${c.expr}" is not an identifier', pos);
			}

			for (f in classType.fields.get()) {
				if (!f.kind.match(FVar(_, _)))
					continue;

				if (!f.meta.has("inject"))
					continue;

				fields.push({
					pos: pos,
					name: f.name,
					meta: null,
					kind: FVar(Context.toComplexType(f.type), null),
					doc: f.doc,
					access: [APublic]
				});
			}
		}

		return fields;
	}

	public static macro function addGameStateBuilderType(type: Expr): Array<Field> {
		final pos = Context.currentPos();

		var value: String;

		switch (type.expr) {
			case EConst(CIdent(name)):
				value = name;

			default:
				Context.fatalError('The provided expression "${type.expr}" is not an identifier', pos);
		}

		final fields = Context.getBuildFields();

		final fun: Function = {
			expr: macro return $i{value},
			ret: (macro:GameStateBuilderType),
			args: []
		};

		fields.push({
			name: "getType",
			access: [APublic, AInline],
			kind: FFun(fun),
			pos: pos
		});

		return fields;
	}

	public static macro function initFromOpts(): Expr {
		final pos = Context.currentPos();

		final opts = Context.getLocalTVars()["opts"];

		if (opts == null)
			Context.fatalError('No local variable named "opts" in caller ${Context.getLocalModule()}:${Context.getLocalMethod()}', pos);

		var optsClass: ClassType;

		switch (opts.t) {
			case TInst(t, _):
				optsClass = t.get();

			default:
				Context.fatalError('Local variable "opts" is not a class instance', pos);
		}

		final localClass = Context.getLocalClass();

		if (localClass == null)
			Context.fatalError("Not called in a class", pos);

		final classFields = localClass.get().fields.get().filter(f -> f.kind.match(FVar(_, _))).map(f -> f.name);
		final optsFields = optsClass.fields.get().map(f -> f.name);

		final exprs = new Array<Expr>();

		for (f in classFields) {
			if (optsFields.contains(f))
				exprs.push(macro $i{f} = opts.$f);
		}

		return macro $b{exprs};
	}

	public static macro function addGameStateBuildMethod(): Array<Field> {
		final pos = Context.currentPos();
		final localClass = Context.getLocalClass();

		if (localClass == null)
			Context.fatalError("Not called in a class", pos);

		final fields = Context.getBuildFields();
		final methods = fields.filter((f) -> ~/(?:build.+)|wireMediators/.match(f.name));

		final exprs = new Array<Expr>();

		for (m in methods)
			exprs.push(macro $i{m.name}());

		fields.push({
			pos: pos,
			name: "build",
			meta: null,
			kind: FFun({
				args: [],
				params: null,
				ret: null,
				expr: macro $b{exprs}
			}),
			doc: null,
			access: [APublic]
		});

		return fields;
	}

	public static macro function addCopyFrom(): Array<Field> {
		final pos = Context.currentPos();
		final fields = Context.getBuildFields();
		final localClassType = Context.getLocalType();

		final exprs = new Array<Expr>();

		final copyFromKind: Function = {
			args: [{name: "other", type: macro:Dynamic}],
			ret: macro:Dynamic
		};

		final copyFromAccess = [APublic];

		switch (localClassType) {
			case TInst(t, params):
				final ct = t.get();

				if (ct.isInterface) {
					fields.push({
						name: "copyFrom",
						pos: pos,
						kind: FFun(copyFromKind),
						access: copyFromAccess,
					});

					return fields;
				}

				var shouldOverride = false;

				function checkForOverride(ct: ClassType) {
					if (ct.superClass == null)
						return;

					final sc = ct.superClass.t.get();

					for (f in sc.fields.get()) {
						if (f.name == "copyFrom") {
							shouldOverride = true;
							break;
						}
					}

					checkForOverride(sc);
				};

				checkForOverride(ct);

				if (shouldOverride) {
					exprs.push(macro super.copyFrom(other));
					copyFromAccess.push(AOverride);
				}

			default:
		}

		for (f in fields) {
			if (f.name == "copyFrom") {
				return fields;
			}
		}

		for (f in fields) {
			final fieldName = f.name;

			if (f.meta == null)
				continue;

			var hasCopyMeta = false;

			for (m in f.meta) {
				if (m.name == "copy") {
					hasCopyMeta = true;
					break;
				}
			}

			if (!hasCopyMeta)
				continue;

			var fieldComplexType: ComplexType;

			switch (f.kind) {
				case FVar(t, _) | FProp(_, _, t, _):
					fieldComplexType = t;

					switch (t) {
						case TPath(p):
							switch (Context.getType(p.name)) {
								case TInst(t, params):
									final ct = t.get();

									var hasICopyFrom = false;

									for (i in ct.interfaces) {
										if (i.t.get().name == "ICopyFrom") {
											hasICopyFrom = true;
											break;
										}
									}

									if (hasICopyFrom) {
										exprs.push(macro $i{fieldName}.copyFrom(untyped other.$fieldName));
									} else {
										exprs.push(macro $i{fieldName} = other.$fieldName);
									}
								case TAbstract(_, _) | TEnum(_, _):
									exprs.push(macro $i{fieldName} = other.$fieldName);
								default:
							}
						default:
					}
				default:
			}
		}

		exprs.push(macro return this);

		copyFromKind.expr = macro $b{exprs};

		fields.push({
			name: "copyFrom",
			pos: pos,
			kind: FFun(copyFromKind),
			access: copyFromAccess
		});

		return fields;
	}
}

package hxrm.generator.extensions;

import hxrm.analyzer.initializers.IInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

class InitializersGeneratorExtension extends GeneratorExtensionBase {

	public override function generate(scope:NodeScope, type:TypeDefinition, pos : Position):Bool {

		if(getCtor(type) == null) {
			return true;
		}

		// initializers
		for (fieldName in scope.initializers.keys()) {
			var initializator : IInitializator = scope.initializers[fieldName];

			if(!Std.is(initializator, BindingInitializator)) {
				continue;
			}

			var bind = cast(initializator, BindingInitializator);

			var value = null;
			try {
				trace('parsing ${bind.value}');
				value = Context.parseInlineString(bind.value, pos);
			} catch (e:Dynamic) {
				throw "can't parse value: " + e;
			}
			var field = scope.getFieldByName(fieldName);

			var valueType = Context.typeof(value);
			var res = if (!Context.unify(valueType, field.type)) {
				// extensions must be here
				var fieldCT = scope.context.getClassType(field.type);
				switch([fieldCT.module, fieldCT.name]) {
					case ["String", "String"]:
						macro Std.string($value);
					case ["Int", "Int"]:
						macro Std.parseInt(Std.string($value));
					case ["Float", "Float"]:
						macro Std.parseFloat(Std.string($value));
					case _:
						throw 'can\'t unify value:$valueType to fieldType:${field.type}';
				}
			}
			else
				value;

			//TODO type.fields.push(macro $i { fieldName } = $res);
		}

		return false;
	}


}

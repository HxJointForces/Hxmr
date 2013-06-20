package hxrm.generator.extensions;

import hxrm.analyzer.initializers.IInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

class InitializersGeneratorExtension extends GeneratorExtensionBase {

	public override function generate(scope:NodeScope, type:TypeDefinition, pos : Position):Bool {

		var ctor : Field = getCtor(type);
		if(ctor == null) {
			return true;
		}
		
		var ctorExprs : Array<Expr> = switch(ctor.kind) {
			case FFun(fun):
				switch(fun.expr.expr) {
					case EBlock(block): block;
					case _: throw "assert";
				}
			case _: throw "assert";
		}

		// initializers
		for (fieldName in scope.initializers.keys()) {
			var initializatorEnum : IInitializator = scope.initializers[fieldName];
			
			var res : Expr = switch(initializatorEnum) {
				case InitBinding(initializator): parseBindingInitializator(scope, type, pos, fieldName, initializator);
				case InitNodeScope(initializator): null;
			}
			
			if(res == null) {
				//TODO remove it
				continue;
			}

			var expr = macro $i { fieldName } = $res;
			
			ctorExprs.push(expr);
		}

		return false;
	}

	function parseBindingInitializator(scope:NodeScope, type:TypeDefinition, pos : Position, fieldName : String, initializator : BindingInitializator) : Expr {
		var value = null;
		try {
			value = Context.parseInlineString(initializator.value, pos);
		} catch (e:Dynamic) {
			throw "can't parse value: " + e;
		}
		var field = scope.getFieldByName(fieldName);
		
		var valueType = Context.typeof(value);
		return if (Context.unify(valueType, field.type)) {
			macro $value;
		} else {
			// extensions must be here
			var fieldCT = scope.context.getClassType(field.type);
			switch([fieldCT.module, fieldCT.name]) {
				case ["String", "String"]	: macro Std.string($value);
				case ["Int", "Int"]			: macro Std.parseInt(Std.string($value));
				case ["Float", "Float"]		: macro Std.parseFloat(Std.string($value));
				case _: throw 'can\'t unify value:$valueType to fieldType:${field.type}';
			}
		}
	}


}

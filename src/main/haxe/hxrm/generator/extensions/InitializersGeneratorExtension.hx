package hxrm.generator.extensions;

import hxrm.analyzer.initializers.IInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;

class InitializersGeneratorExtension extends GeneratorExtensionBase {

	public override function generate(context:GeneratorContext, scope:GeneratorScope):Bool {

		if(scope.ctor == null) {
			return true;
		}
		
		// initializers
		var initializers = context.node.initializers;
		for (fieldName in initializers.keys()) {
			var initializatorEnum : IInitializator = initializers[fieldName];
			
			var res : Expr = switch(initializatorEnum) {
				case InitBinding(initializator): parseBindingInitializator(context, scope, fieldName, initializator);
				case InitNodeScope(initializator): null;
			}
			
			if(res != null) {
				var expr = macro $i { fieldName } = $res;
			
				scope.ctorExprs.push(expr);
			}
		}

		return false;
	}

	function parseBindingInitializator(context:GeneratorContext, scope:GeneratorScope, fieldName:String, initializator : BindingInitializator) : Expr {
		var value = null;
		try {
			value = Context.parseInlineString(initializator.value, context.pos);
		} catch (e:Dynamic) {
			throw "can't parse value: " + e;
		}
		var field = context.node.getFieldByName(fieldName);
		
		var valueType = Context.typeof(value);
		return if (Context.unify(valueType, field.type)) {
			macro $value;
		} else {
			// extensions must be here
			var fieldCT = context.node.context.getClassType(field.type);
			switch([fieldCT.module, fieldCT.name]) {
				case ["String", "String"]	: macro Std.string($value);
				case ["Int", "Int"]			: macro Std.parseInt(Std.string($value));
				case ["Float", "Float"]		: macro Std.parseFloat(Std.string($value));
				case _: throw 'can\'t unify value:$valueType to fieldType:${field.type}';
			}
		}
	}


}

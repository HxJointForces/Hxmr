package hxrm.generator.extensions;

import haxe.macro.Context;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.FieldInitializator;
import haxe.macro.Expr;
import hxrm.analyzer.NodeScope;
import hxrm.generator.GeneratorScope;
import hxrm.HxmrContext;

class ChildrenGeneratorExtension extends InitializersGeneratorExtension {

	override public function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		if(scope.ctor == null) {
			return true;
		}

		for(childInitializer in scope.context.node.children) {
			var id : String = childInitializer.fieldName;
			var initializerId : String = generateInitializerName(id);
			
			var expr = macro $i { scope.context.node.defaultProperty }.push($i {initializerId}());
			
			scope.ctorExprs.push(expr);
		}

		return false;
	}
}

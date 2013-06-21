package hxrm.generator.extensions;

import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.NodeScopeInitializator;
import haxe.macro.Expr;
import hxrm.analyzer.NodeScope;

class ChildrenGeneratorExtension extends InitializersGeneratorExtension {

	override public function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		if(scope.ctor == null) {
			return true;
		}

		var defaultProperty : String;
		for(field in scope.context.node.classFields) {
			if(!field.meta.has("hxmrDefaultProperty")) {
				continue;
			}

			if(defaultProperty != null) {
				//TODO DUPLICATE_DEFAULT_PROPERTY with use pos from base class!!!
				return false;
			}

			defaultProperty = field.name;
		}
		
		if(defaultProperty == null && scope.context.node.children.length > 0) {

			// TODO error default property not found
			trace("default property not found");
			return false;
		}
		
		parseBindingInitializator(context, scope, new BindingInitializator(defaultProperty, "[]"));

		for(childInitializer in scope.context.node.children) {
			var id : String = childInitializer.id;
			var initializerId : String = generateInitializerName(id);
			
			var expr = macro $i { defaultProperty }.push($i {initializerId}());
			
			scope.ctorExprs.push(expr);
		}

		return false;
	}
}

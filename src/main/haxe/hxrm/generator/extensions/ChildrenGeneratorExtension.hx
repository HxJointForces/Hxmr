package hxrm.generator.extensions;

import haxe.macro.Type.ClassField;
import haxe.macro.Expr.TypeDefinition;
import hxrm.analyzer.NodeScope;

class ChildrenGeneratorExtension extends GeneratorExtensionBase {

	override public function generate(context:GeneratorContext, scope:GeneratorScope):Bool {

		if(getCtor(type) == null) {
			return true;
		}

		var defaultProperty : ClassField;
		for(field in scope.classFields) {
			if(!field.meta.has("hxmrDefaultProperty")) {
				continue;
			}

			if(defaultProperty != null) {
				//TODO use pos from base class!!!
				//context.error(new ChildrenGeneratorExtension(DUPLICATE_DEFAULT_PROPERTY));
				return false;
			}

			defaultProperty = field;
		}
		
		if(defaultProperty == null && scope.children.length > 0) {
			// TODO error default property not found
			return false;
		}

		//TODO this code should be rewriten because it doesn't seems to be ok
		for (child in scope.children) {
			var childExpr = generateChild(child, scope);
			if (childExpr != null) {
				//type.fields = ctorFields.concat(childExpr);
			}
		}

		return false;
	}

	function generateChild(child:NodeScope, root:NodeScope):Array<Expr> {
		return null;
		
		var res = [];

		for (c in child.children) {
			var genChild = generateChild(c, child);
			if (genChild != null) res = res.concat(genChild);
		}


		return res.length > 0 ? res : null;
	}
}

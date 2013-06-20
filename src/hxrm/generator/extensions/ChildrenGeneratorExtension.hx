package hxrm.generator.extensions;

import haxe.macro.Type.ClassField;
import haxe.macro.Expr.TypeDefinition;
import hxrm.analyzer.NodeScope;
class ChildrenGeneratorExtension extends GeneratorExtensionBase {


	override public function generate(scope:NodeScope, type:TypeDefinition, pos : Position):Bool {

		var defaultProperty : ClassField;
		for(field in scope.classFields) {
			if(!field.meta.has("hxmrDefaultProperty")) {
				continue;
			}

			if(defaultProperty != null) {
				//TODO use pos from base class!!!
				//context.error(new ChildrenAnalyzerError(DUPLICATE_DEFAULT_PROPERTY));
				return false;
			}

			defaultProperty = field;
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

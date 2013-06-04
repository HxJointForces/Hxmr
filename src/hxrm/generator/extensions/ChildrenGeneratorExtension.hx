package hxrm.generator.extensions;

import haxe.macro.Expr.TypeDefinition;
import hxrm.analyzer.NodeScope;
class ChildrenGeneratorExtension extends GeneratorExtensionBase {


	override public function generate(scope:NodeScope, type:TypeDefinition, pos : Position):Bool {

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
		var fieldName = child.context.node.name.localPart;
		
		if (root.getFieldByName(fieldName) == null) {
			throw 'class ${child.type} doesn\'t have field $fieldName';
		}
		var res = [];

		for (c in child.children) {
			var genChild = generateChild(c, child);
			if (genChild != null) res = res.concat(genChild);
		}


		return res.length > 0 ? res : null;
	}
}

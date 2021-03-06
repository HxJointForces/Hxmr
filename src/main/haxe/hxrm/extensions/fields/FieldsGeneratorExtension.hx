package hxrm.extensions.fields;

import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import hxrm.generator.GeneratorScope;
import hxrm.extensions.base.IGeneratorExtension;

class FieldsGeneratorExtension implements IGeneratorExtension {
    public function new() {

    }

	public function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		processScope(context, scope, scope.context.node, scope.ctorExprs);

		return false;
	}

	function processScope(context : HxmrContext, scope : GeneratorScope, nodeScope : NodeScope, exprs : Array<Expr>) : Void {

        for (fieldName in nodeScope.fields.keys()) {
            parseFieldInitializator(context, scope, fieldName, nodeScope.fields.get(fieldName));
        }
    }

    function parseFieldInitializator(context : HxmrContext, scope : GeneratorScope, fieldName : String, fieldType : ComplexType) : Void {

        var field : Field = {
            name : fieldName,
            doc : null,//"autogenerated NodeScope field " + initializator.type,
            access : [APublic],
            pos : scope.context.pos,
            kind : FVar(fieldType)
        };
        scope.typeDefinition.fields.unshift(field);
    }
}

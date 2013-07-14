package hxrm.extensions.properties;

import hxrm.extensions.fields.FieldsExtension;
import hxrm.extensions.properties.initializers.IItor;
import hxrm.extensions.base.IGeneratorExtension;
import haxe.macro.Context;
import hxrm.HxmrContext;
import hxrm.generator.GeneratorScope;
import haxe.macro.Context;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;

class PropertiesGeneratorExtension implements IGeneratorExtension {

    public function new() {

    }

	public function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		if(scope.ctorExprs == null || scope.itorExprs == null) {
			return true;
		}
		
		processScope(context, scope, scope.context.node, "this");

		return false;
	}

	public function processScope(context : HxmrContext, scope : GeneratorScope, nodeScope : NodeScope, forField : String) : Void {
    
        var exprs : Array<Expr> = scope.itorExprs.get(forField);

        for (fieldName in nodeScope.initializers.keys()) {
            var res = parseBindingInitializator(context, scope, nodeScope, fieldName, nodeScope.initializers.get(fieldName));
            exprs.push(macro $i{forField}.$fieldName = $res);
        }
    }

    function parseBindingInitializator(context:HxmrContext, scope:GeneratorScope, nodeScope : NodeScope, fieldName : String, iitor : IItor) : Expr {

        return switch(iitor) {
            case InitValue(itor):
                var value = getValue(scope, itor.value);
                macro $value;

            case InitArray(itor):
                var values : Array<Expr> = [];
                for(childInit in itor.value) {
                    values.push(parseBindingInitializator(context, scope, nodeScope, childInit.name, childInit.itor));
                }
                {
                    expr : EArrayDecl(values),
                    pos : Context.currentPos()
                };

            case InitNodeScope(itor):
                processScope(context, scope, itor.value, fieldName);

                var initFunctionName = context.getExtension(FieldsExtension).generateInitializerName(fieldName);
                macro $i { initFunctionName } ();
        }
    }

    function getValue(scope : GeneratorScope, value : Dynamic) : Expr {
        try {
            return Context.parse(value, scope.context.pos);
        } catch (e:Dynamic) {
            trace(e);
            //TODO throw " can't parse value: " + e;
        }
        return null;
    }

}

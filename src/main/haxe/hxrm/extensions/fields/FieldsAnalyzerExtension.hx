package hxrm.extensions.fields;

import hxrm.utils.TypeUtils;
import hxrm.extensions.properties.PropertiesExtension;
import haxe.macro.Context;
import hxrm.extensions.properties.initializers.IItor;
import hxrm.extensions.base.INodeAnalyzerExtension;
import hxrm.analyzer.QName;
import haxe.macro.Type;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import haxe.macro.Type.ClassField;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
import haxe.macro.Expr;

enum FieldsAnalyzerErrorType {
    DUPLICATE(name:String);
}

class FieldsAnalyzerError extends NodeAnalyzerError {
    public function new(type : FieldsAnalyzerErrorType, ?pos : Pos) {
        super(type, pos);
    }
}


class FieldsAnalyzerExtension implements INodeAnalyzerExtension {

    public function new() {
    
    }

    public function analyze(context : HxmrContext, scope:NodeScope):Bool {
    
        if(scope.initializers == null) {
            return true;
        }
        
        trace(scope.context.node);
        TypeUtils.prettyPrintType(scope.initializers);

        for (value in scope.initializers.iterator()) {
            parseValueForField(context, scope, value);
        }

        return false;
    }
    
    public function parseValueForField(context : HxmrContext, scope1 : NodeScope, value : IItor) {
        var topScope : NodeScope = scope1.getTopScope();
        var valueNode : MXMLNode = switch(value) {
            case InitValue(itor): itor.node;
            case InitArray(itor): itor.node;
            case InitNodeScope(itor): itor.node;
        }
        if(valueNode == null) {
            return;
        }
        var hasOwnField : Bool = switch(value) {
            case InitValue(itor) if(topScope.getNodeId(valueNode) != null): true;
            case InitArray(itor) if(topScope.getNodeId(valueNode) != null): true;
            case InitNodeScope(itor): true;
            case _: false;
        }
        if(hasOwnField) {
            var fieldName = topScope.getFieldNameForNode(valueNode);
            rememberField(context, topScope, fieldName, getFieldType(context, topScope, valueNode), valueNode.position);
            context.getExtension(PropertiesExtension).analyzer.rememberProperty(context, topScope, fieldName, value, valueNode.position);
        }

        switch(value) {
            case InitArray(itor):
                for(child in itor.value) {
                    var value = child.itor;
                    parseValueForField(context, topScope, value);
                }
            case _:
        }
    }

    public function getFieldType(context : HxmrContext, scope : NodeScope, valueNode : MXMLNode) : ComplexType {
        var qName : QName = scope.context.resolveQName(valueNode.name);
        return switch(scope.context.resolveQName(valueNode.name).toHaxeTypeId()){
            case "Array":
                TPath({
                    pack : [],
                    name : "Array",
                    params : [TPType(TPath({
                        pack : [],
                        name : "Dynamic",
                        params : []
                    }))]
                });
            case _:
                Context.toComplexType(scope.context.getType(qName));
        }
    }

    function rememberField(context : HxmrContext, scope : NodeScope, fieldName : String, fieldType : ComplexType, pos:Pos) : Void {

        if(scope.fields == null) {
            scope.fields = new Map();
        }
        
        if(scope.fields.exists(fieldName)) {
            context.error(new FieldsAnalyzerError(DUPLICATE(fieldName), pos));
            return;
        }

        scope.fields.set(fieldName, fieldType);
    }

}

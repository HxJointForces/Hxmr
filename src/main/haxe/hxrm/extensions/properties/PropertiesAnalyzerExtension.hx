package hxrm.extensions.properties;

import haxe.macro.Context;
import hxrm.extensions.properties.initializers.IItor;
import hxrm.extensions.properties.initializers.Itor;
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

enum PropertiesAnalyzerErrorType {
    UNKNOWN_FIELD(name:String);
    VALUE_MUST_BE_NODE_OR_CDATA;
    VALUE_MUST_BE_ONE_NODE;
    ATTRIBUTES_IN_PROPERTY;
    DUPLICATE;
    EMPTY_PROPERTY_INITIALIZER;
}

class PropertiesAnalyzerError extends NodeAnalyzerError {
    public function new(type : PropertiesAnalyzerErrorType, ?pos : Pos) {
        super(type, pos);
    }
}

class PropertiesAnalyzerExtension implements INodeAnalyzerExtension {

    public function new() {
    
    }

    public function analyze(context : HxmrContext, scope:NodeScope):Bool {
    
        if(scope.classFields == null) {
            return true;
        }

        var node : MXMLNode = scope.context.node;
        var poses = node.attributesPositions;
        for (attributeQName in node.attributes.keys()) {
            var value : String = node.attributes.get(attributeQName);
            matchAttribute(context, scope, attributeQName, value, poses.get(attributeQName));
        }

        for (childNode in node.children) {
            matchChild(context, scope, childNode);
        }

        return false;
    }

    public function matchAttribute(context : HxmrContext, scope:NodeScope, attributeQName:MXMLQName, value:String, pos:Pos):Void {

        if(attributeQName.namespace != scope.context.node.name.namespace && attributeQName.namespace != MXMLQName.ASTERISK) {
            return;
        }

        if(attributeQName.localPart == "id") {
            return;
        }

        if(scope.getFieldByName(attributeQName.localPart) == null) {
            context.error(new PropertiesAnalyzerError(UNKNOWN_FIELD(attributeQName.localPart), pos));
            return;
        }

        rememberProperty(context, scope, attributeQName.localPart, InitValue(new Itor<Dynamic>(value)), pos);
    }

    public function matchChild(context : HxmrContext, scope:NodeScope, setterNode:MXMLNode):Void {

        if(!isInnerProperty(scope, setterNode)) {
            return;
        }

        if(setterNode.attributes.iterator().hasNext()) {
            context.error(new PropertiesAnalyzerError(ATTRIBUTES_IN_PROPERTY, setterNode.position));
            return;
        }

        var hasCDATA = (setterNode.cdata != null && setterNode.cdata.length > 0);

        if((setterNode.children.length > 1 && hasCDATA) || (setterNode.children.length == 0 && !hasCDATA)) {
            context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_NODE_OR_CDATA, setterNode.position));
            return null;
        }

        var matchResult = if(setterNode.cdata != null && setterNode.cdata.length > 0) {
            InitValue(new Itor<Dynamic>(setterNode.cdata));
        } else {
            if(setterNode.children.length != 1) {
                context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_ONE_NODE, setterNode.position));
                return null;
            }

            var valueNode = setterNode.children[0];

            parseValue(context, scope, valueNode);
        }

        if(matchResult != null) {
            rememberProperty(context, scope, setterNode.name.localPart, matchResult, setterNode.position);
        }
    }

    public function parseValue(context : HxmrContext, scope:NodeScope, valueNode : MXMLNode) : IItor {

        var value = matchValue(context, scope, valueNode);

        var hasOwnField : Bool = switch(value) {
            case InitValue(itor) if(scope.getNodeId(valueNode) != null): true;
            case InitArray(itor) if(scope.getNodeId(valueNode) != null): true;
            case InitNodeScope(itor): true;
            case _: false;
        }
        if(hasOwnField) {
            var field = {name : scope.getFieldNameForNode(valueNode), type : getFieldType(context, scope, valueNode)};

            rememberField(context, scope.getTopScope(), field, valueNode.position);
            rememberProperty(context, scope.getTopScope(), field.name, value, valueNode.position);
        }
        return value;
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
                        params : []}
                    ))]}
                );
            case _:
                Context.toComplexType(scope.context.getType(qName));
        }
    }

    public function matchValue(context : HxmrContext, scope:NodeScope, innerChild:MXMLNode) : IItor {

        return switch(scope.context.resolveQName(innerChild.name).toHaxeTypeId()) {

            case "String", "Int", "Float":
                InitValue(new Itor<Dynamic>(innerChild.cdata));

            case "Array":
                var childs : Array<{name : String, itor : IItor}> = [];

                for(child in innerChild.children) {
                    childs.push({name : scope.getFieldNameForNode(child), itor : parseValue(context, scope, child)});
                }

                InitArray(new Itor<Array<{name : String, itor : IItor}>>(childs));

            case type:
                //trace("_ " + type);
                var childScope : NodeScope = context.analyzer.analyze(context, innerChild, scope);

                if(childScope == null) {
                    //TODO logging?
                    trace("childScope is null");
                    return null;
                }
                InitNodeScope(new Itor<NodeScope>(childScope));
        }

    }

    function rememberField(context : HxmrContext, scope : NodeScope, field : FieldDeclaration, pos:Pos) : Void {

        for(iterField in scope.fields) {
            if(iterField.name == field.name) {
                context.error(new PropertiesAnalyzerError(DUPLICATE, pos));
                return;
            }
        }

        scope.fields.unshift(field);
    }

    public function rememberProperty(context : HxmrContext, scope : NodeScope, fieldName : String, value:IItor, pos:Pos) : Void {

        if(scope.initializers.exists(fieldName)) {
            context.error(new PropertiesAnalyzerError(DUPLICATE, pos));
            return;
        }

        scope.initializers.set(fieldName, value);
    }

    public function isInnerProperty(scope : NodeScope, child : MXMLNode) : Bool {
        if(child.name.namespace == scope.context.node.name.namespace) {
            if(scope.getFieldByName(child.name.localPart) != null) {
                return true;
            }
        }
        return false;
    }
}
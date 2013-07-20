package hxrm.extensions.properties;

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

enum PropertiesAnalyzerErrorType {
    UNKNOWN_FIELD(name:String);
    VALUE_MUST_BE_NODE_OR_CDATA;
    VALUE_MUST_BE_ONE_NODE;
    ATTRIBUTES_IN_PROPERTY;
    DUPLICATE(name:String);
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
        
        if(scope.initializers == null) {
            scope.initializers = new Map();
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

        rememberProperty(context, scope, attributeQName.localPart, InitValue(new Itor<Dynamic>(value, null)), pos);
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
            InitValue(new Itor<Dynamic>(setterNode.cdata, setterNode));
        } else {
            if(setterNode.children.length != 1) {
                context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_ONE_NODE, setterNode.position));
                return null;
            }

            var valueNode = setterNode.children[0];

            matchValue(context, scope, valueNode);
        }

        if(matchResult != null) {
            rememberProperty(context, scope, setterNode.name.localPart, matchResult, setterNode.position);
        }
    }

    public function matchValue(context : HxmrContext, scope:NodeScope, innerChild:MXMLNode) : IItor {

        return switch(scope.context.resolveQName(innerChild.name).toHaxeTypeId()) {

            case "String", "Int", "Float":
                InitValue(new Itor<Dynamic>(innerChild.cdata, innerChild));

            case "Array":
                var childs : Array<{name : String, itor : IItor}> = [];

                for(child in innerChild.children) {
                    childs.push({name : scope.getFieldNameForNode(child), itor : matchValue(context, scope, child)});
                }

                InitArray(new Itor<Array<{name : String, itor : IItor}>>(childs, innerChild));

            case type:
                //trace("_ " + type);
                var childScope : NodeScope = context.analyzer.analyze(context, innerChild, scope);

                if(childScope == null) {
                    //TODO logging?
                    trace("childScope is null");
                    return null;
                }
                InitNodeScope(new Itor<NodeScope>(childScope, innerChild));
        }
    }

    public function rememberProperty(context : HxmrContext, scope : NodeScope, fieldName : String, value:IItor, pos:Pos) : Void {

        if(scope.initializers.exists(fieldName)) {
            //context.error(new PropertiesAnalyzerError(DUPLICATE(fieldName), pos));
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
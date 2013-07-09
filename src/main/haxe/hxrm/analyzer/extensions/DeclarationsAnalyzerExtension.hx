package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class DeclarationsAnalyzerExtension extends PropertiesAnalyzerExtension {

    override public function analyze(context : HxmrContext, scope:NodeScope):Bool {
        var node : MXMLNode = scope.context.node;
        
        for (child in node.children) {

            if(child.name.localPart != "Declarations"){
                continue;
            }

            // TODO remove hardcoded URL
            if(MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace) != "http://haxe.org/hxmr/") {
                continue;
            }

            matchDeclaration(context, scope, child);
        }
        return false;
    }

    function matchDeclaration(context : HxmrContext, scope:NodeScope, declarationNode:MXMLNode):Void {

        for(valueNode in declarationNode.children)
        {
            //var matchResult = matchValue(context, scope, child);

            //scope.fields.push(matchResult);

            //TODO remove code duplicates
            var qName : QName = scope.context.resolveQName(valueNode.name);

            var type = scope.context.getType(qName);
            var fieldDescription = {name : scope.getFieldNameForNode(valueNode), type : type};

            var value = matchValue(context, scope, valueNode);
            
            rememberField(context, scope, fieldDescription, value, valueNode.position);
        }
    }

}

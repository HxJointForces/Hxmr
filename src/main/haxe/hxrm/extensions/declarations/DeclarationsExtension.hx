package hxrm.extensions.declarations;

import hxrm.extensions.properties.PropertiesExtension;
import hxrm.generator.GeneratorScope;
import hxrm.extensions.base.IHxmrExtension;
import hxrm.analyzer.QName;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class DeclarationsExtension implements IHxmrExtension {

    public function new() {
    
    }

    public function analyze(context : HxmrContext, scope:NodeScope):Bool {
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

    // return true if it needs one more iteration
    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
        return false;
    }

    function matchDeclaration(context : HxmrContext, scope:NodeScope, declarationNode:MXMLNode):Void {

        for(valueNode in declarationNode.children)
        {
            context.getExtension(PropertiesExtension).analyzer.parseValue(context, scope, valueNode);
        }
    }

}

package hxrm.extensions.script;

import hxrm.generator.GeneratorScope;
import hxrm.extensions.base.IHxmrExtension;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class ScriptBlockExtension implements IHxmrExtension {

    public function new() {
    }

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		var node : MXMLNode = scope.context.node;
		for (childNode in node.children) {
				matchChild(context, scope, childNode);
		}
		return false;
	}

    // return true if it needs one more iteration
    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
        return false;
    }

	function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):Void {

		if(child.name.localPart != "Script"){
			return;
		}
		
		// TODO remove hardcoded URL
		if(MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace) != "http://haxe.org/hxmr/") {
			return;
		}

		trace('Script block with code:${child.cdata}');
	}

}

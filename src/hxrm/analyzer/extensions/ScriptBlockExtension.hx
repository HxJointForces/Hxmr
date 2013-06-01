package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class ScriptBlockExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(scope:NodeScope, node:MXMLNode):Bool {
		for (childNode in node.children) {
				matchChild(scope, childNode);
		}
		return false;
	}

	function matchChild(scope:NodeScope, child:MXMLNode):Void {
		// TODO remove hardcoded URL
		if(MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace) == "http://haxe.org/hxmr/" && child.name.localPart == "Script") {
			trace("Script block!");
		}
	}

}

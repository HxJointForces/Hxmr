package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLNode;

class ScriptBlockExtension extends NodeAnalyzerExtensionBase {

	override public function matchChild(scope:NodeScope, child:MXMLNode):Void {
		// TODO remove hardcoded URL
		if(child.namespaces.get(child.name.namespace) == "http://haxe.org/hxmr/" && child.name.localPart == "Script") {
			
			trace("Script block!");
			return;
		}
		
		return super.matchChild(scope, child);
	}

}

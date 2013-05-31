package hxrm.analyzer.childrenMatcher;

import hxrm.parser.mxml.MXMLNode;

class ScriptBlockChildrenMatcher extends ChildrenMatcherBase {
	public function new() {
		super();
	}

	override public function match(scope:NodeScope, child:MXMLNode):Void {
		// TODO remove hardcoded URL
		if(child.namespaces.get(child.name.namespace) != "http://haxe.org/hxmr/") {
			return super.match(scope, child);
		}
		if(child.name.localPart == "Script") {

			trace("Script block!");
		}
	}

}

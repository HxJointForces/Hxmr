package hxrm.analyzer.extensions;

import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class DefaultPropertyExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(scope:NodeScope, node:MXMLNode):Bool {
		for (childNode in node.children) {
			matchChild(scope, childNode);
		}
		
		return false;
	}

	function matchChild(scope:NodeScope, child:MXMLNode):Void {
	
		//TODO better typename checking
		if(StringTools.startsWith(MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace), "http://")) {
			return;
		}
		
		var childScope : NodeScope = analyzer.analyze(child);
		
		if(childScope == null) {
			return;
		}
		
		scope.children.push(childScope);
	}


}

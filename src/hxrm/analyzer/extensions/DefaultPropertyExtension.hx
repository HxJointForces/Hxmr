package hxrm.analyzer.extensions;

import hxrm.utils.TypeUtils;
import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class DefaultPropertyExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(scope:NodeScope):Bool {

		if(scope.classFields == null) {
			return true;
		}
		
		var node : MXMLNode = scope.context.node;
		for (childNode in node.children) {
			matchChild(scope, childNode);
		}
		
		return false;
	}

	function matchChild(scope:NodeScope, child:MXMLNode):Void {
	
		if(child.name.namespace == scope.context.node.name.namespace) {
			for(field in scope.classFields) {
				if(child.name.localPart == field.name) {
					return;
				}
			}
		}
		
		//TODO better typename checking
		var resolveNamespaceValue = MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace);
		if(StringTools.startsWith(resolveNamespaceValue, "http://")) {
			return;
		}
		
		var childScope : NodeScope = analyzer.analyze(child);
		
		if(childScope == null) {
			trace("childScope is null");
			return;
		}
		
		scope.children.push(childScope);
	}


}

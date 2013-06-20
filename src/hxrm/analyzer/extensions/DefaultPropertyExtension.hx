package hxrm.analyzer.extensions;

import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

class DefaultPropertyExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(context : HxmrContext, scope:NodeScope):Bool {

		if(scope.children == null) {
			scope.children = [];
		}
		
		if(scope.classFields == null) {
			return true;
		}
		
		var node : MXMLNode = scope.context.node;

		if(node.children.length > 0 && node.cdata != null && node.cdata.length > 0) {
			throw "You cann't mix cdata with inner tags!\n" + node;
		}
		
		for (childNode in node.children) {
			matchChild(context, scope, childNode);
		}
		
		return false;
	}

	function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):Void {
	
		if(child.name.namespace == scope.context.node.name.namespace) {
			if(scope.getFieldByName(child.name.localPart) != null) {
				return;
			}
		}
		
		//TODO better typename checking
		var resolveNamespaceValue = MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace);
		if(StringTools.startsWith(resolveNamespaceValue, "http://")) {
			return;
		}
		
		var childScope : NodeScope = analyzer.analyze(context, child);
		
		if(childScope == null) {
			trace("childScope is null");
			throw "childScope is null";
		}
		
		scope.children.push(childScope);
	}


}

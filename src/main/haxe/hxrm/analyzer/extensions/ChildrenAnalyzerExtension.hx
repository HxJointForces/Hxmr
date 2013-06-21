package hxrm.analyzer.extensions;

import hxrm.analyzer.initializers.NodeScopeInitializator;
import hxrm.parser.mxml.MXMLQName;
import hxrm.analyzer.initializers.NodeScopeInitializator;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

enum ChildrenAnalyzerErrorType {
	CDATA_WITH_INNER_TAGS;
}

class ChildrenAnalyzerError extends NodeAnalyzerError {
	public function new(type : ChildrenAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

class ChildrenAnalyzerExtension extends PropertiesAnalyzerExtension {

	override public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		
		if(scope.initializers == null) {
			return true;
		}

		scope.children = [];
		
		var node : MXMLNode = scope.context.node;

		if(node.children.length > 0 && node.cdata != null && node.cdata.length > 0) {
			context.error(new ChildrenAnalyzerError(CDATA_WITH_INNER_TAGS));
			return false;
		}
		
		for (childNode in node.children) {
			matchChild(context, scope, childNode);
		}
		
		return false;
	}

	override function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):Void {
	
		if(isInnerProperty(scope, child)) {
			return;
		}
		
		//TODO better typename checking
		var resolveNamespaceValue = MXMLQNameUtils.resolveNamespaceValue(child, child.name.namespace);
		if(StringTools.startsWith(resolveNamespaceValue, "http://")) {
			return;
		}
		
		var childScope : NodeScope = analyzer.analyze(context, child);
		
		if(childScope == null) {
			//TODO logging?
			trace("childScope is null");
			return;
		}

		var innerChildId = scope.getFieldNameForNode(child);
		var nodeScopeInitializer = new NodeScopeInitializator(innerChildId, childScope);
		rememberProperty(context, scope, InitNodeScope(nodeScopeInitializer));
		
		scope.children.push(nodeScopeInitializer);
	}


}

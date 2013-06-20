package hxrm.analyzer.extensions;

import hxrm.HxmrContext.FilePos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

enum DefaultPropertyAnalyzerErrorType {
	CDATA_WITH_INNER_TAGS;
}

class DefaultPropertyAnalyzerError extends NodeAnalyzerError {
	public var type : DefaultPropertyAnalyzerErrorType;

	public function new(type : DefaultPropertyAnalyzerErrorType, ?pos : FilePos) {
		super(pos);
		this.type = type;
	}
}

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
			context.error(new DefaultPropertyAnalyzerError(DefaultPropertyAnalyzerErrorType.CDATA_WITH_INNER_TAGS));
			return false;
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
			//TODO logging?
			trace("childScope is null");
			return;
		}
		
		scope.children.push(childScope);
	}


}

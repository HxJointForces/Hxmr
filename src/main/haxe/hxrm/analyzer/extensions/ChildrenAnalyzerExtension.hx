package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeScope;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.FieldInitializator;
import hxrm.HxmrContext;
import hxrm.parser.mxml.MXMLQName;
import hxrm.analyzer.initializers.FieldInitializator;
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

		if(scope.children == null) {
			scope.children = [];
		}
		
		var node : MXMLNode = scope.context.node;
	
		if(scope.initializers == null) {
			return true;
		}

		if(node.children.length > 0 && node.cdata != null && node.cdata.length > 0) {
			context.error(new ChildrenAnalyzerError(CDATA_WITH_INNER_TAGS));
			return false;
		}

		if(node.children.length == 0) {
			return false;
		}

		var defaultPropertyNode : MXMLNode = new MXMLNode();
		defaultPropertyNode.name = new MXMLQName("*", "Array");
		var defaultPropertyNodeScope : NodeScope = analyzer.analyze(context, defaultPropertyNode);
		//TODO causes bugs
		
		for (childNode in node.children) {
			matchDefaultProperyChild(context, scope, defaultPropertyNodeScope, childNode);
		}
		
		if(defaultPropertyNodeScope.children.length > 0) {

			for(field in scope.classFields) {
				if(!field.meta.has("hxmrDefaultProperty")) {
					continue;
				}

				if(scope.defaultProperty != null) {
					//TODO DUPLICATE_DEFAULT_PROPERTY with use pos from base class!!!
					return false;
				}

				scope.defaultProperty = field.name;
			}

			if(scope.defaultProperty == null && node.children.length > 0) {
				// TODO error default property not found
				trace("default property not found");
				return false;
			}

			rememberProperty(context, scope, scope.defaultProperty, InitBinding(new BindingInitializator(scope.defaultProperty, defaultPropertyNodeScope)));

		}
		
		return false;
	}

	function matchDefaultProperyChild(context : HxmrContext, scope:NodeScope, defaultPropertyNodeScope : NodeScope, child:MXMLNode):Void {
	
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
		var nodeScopeInitializer = new FieldInitializator(innerChildId, childScope, childScope.type);
		rememberProperty(context, scope, innerChildId, InitNodeScope(nodeScopeInitializer));

		defaultPropertyNodeScope.children.push(nodeScopeInitializer);
	}


}

package hxrm.analyzer.extensions;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import haxe.macro.Type.ClassField;
import hxrm.analyzer.initializers.FieldInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

enum PropertiesAnalyzerErrorType {
	UNKNOWN_FIELD;
	VALUE_MUST_BE_NODE_OR_CDATA;
	VALUE_MUST_BE_ONE_NODE;
	ATTRIBUTES_IN_PROPERTY;
	DUPLICATE;
}

class PropertiesAnalyzerError extends NodeAnalyzerError {
	public function new(type : PropertiesAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

class PropertiesAnalyzerExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(context : HxmrContext, scope:NodeScope):Bool {
	
		if(scope.initializers == null) {
			scope.initializers = [];
		}
	
		var node : MXMLNode = scope.context.node;
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(context, scope, attributeQName, value);
		}
		
		for (childNode in node.children) {
			matchChild(context, scope, childNode);
		}

		return false;
	}

	function matchAttribute(context : HxmrContext, scope:NodeScope, attributeQName:MXMLQName, value:String):Void {

		if(attributeQName.namespace != scope.context.node.name.namespace && attributeQName.namespace != MXMLQName.ASTERISK) {
			return;
		}
		
		if(attributeQName.localPart == "id") {
			return;
		}
		
		if(scope.getFieldByName(attributeQName.localPart) == null) {
			context.error(new PropertiesAnalyzerError(UNKNOWN_FIELD));
			return;
		}
		
		rememberProperty(context, scope, InitBinding(new BindingInitializator(attributeQName.localPart, '"value"')));
	}

	function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):Void {
	
		if(!isInnerProperty(scope, child)) {
			return;
		}

		if(child.attributes.iterator().hasNext()) {
			context.error(new PropertiesAnalyzerError(ATTRIBUTES_IN_PROPERTY));
			return;
		}

		var hasCDATA = (child.cdata != null && child.cdata.length > 0);
		
		if((child.children.length > 1 && hasCDATA) || (child.children.length == 0 && !hasCDATA)) {
			context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_NODE_OR_CDATA));
			return;
		}
		
		if(child.children.length > 0) {
			// TODO ArrayInitializers
			if(child.children.length > 1) {
				context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_ONE_NODE));
				return;
			}
			var innerChild : MXMLNode = child.children[0];
			
			var childScope : NodeScope = analyzer.analyze(context, innerChild);

			if(childScope == null) {
				//TODO logging?
				trace("childScope is null");
				return;
			}

			var innerChildId : String = scope.getFieldNameForNode(innerChild);
			rememberProperty(context, scope, InitNodeScope(new FieldInitializator(innerChildId, '"${innerChild.cdata}"', childScope.type)));
			rememberProperty(context, scope, InitBinding(new BindingInitializator(child.name.localPart, innerChildId)));
			
		} else if(hasCDATA) {
			rememberProperty(context, scope, InitBinding(new BindingInitializator(child.name.localPart, '"${child.cdata}"')));
		}
	}

	function rememberProperty(context : HxmrContext, scope : NodeScope, value:IInitializator) : Void {

		var propName : String = getInitializatorFieldName(value);
		
		for(initializator in scope.initializers) {
			if(getInitializatorFieldName(initializator) == propName) {
				context.error(new PropertiesAnalyzerError(DUPLICATE));
				return;
			}
		}

		scope.initializers.push(value);
	}

	function getInitializatorFieldName(value:IInitializator) : String {
		return switch(value) {
			case InitBinding(bindingInitializator): bindingInitializator.fieldName;
			case InitNodeScope(nodeInitializator): nodeInitializator.fieldName;
		}
	}

	function isInnerProperty(scope : NodeScope, child : MXMLNode) : Bool {
		if(child.name.namespace == scope.context.node.name.namespace) {
			if(scope.getFieldByName(child.name.localPart) != null) {
				return true;
			}
		}
		return false;
	}
}

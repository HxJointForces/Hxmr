package hxrm.analyzer.extensions;

import hxrm.analyzer.initializers.FieldInitializator;
import haxe.macro.Context;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import haxe.macro.Type.ClassField;
import hxrm.analyzer.initializers.FieldInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

enum PropertiesAnalyzerErrorType {
	UNKNOWN_FIELD(name:String);
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
			scope.initializers = new Map();
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
			context.error(new PropertiesAnalyzerError(UNKNOWN_FIELD(attributeQName.localPart)));
			return;
		}
		
		rememberProperty(context, scope, attributeQName.localPart, InitBinding(new BindingInitializator(null, value)));
	}

	function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):IInitializator {
	
		if(!isInnerProperty(scope, child)) {
			return null;
		}

		if(child.attributes.iterator().hasNext()) {
			context.error(new PropertiesAnalyzerError(ATTRIBUTES_IN_PROPERTY));
			return null;
		}

		var hasCDATA = (child.cdata != null && child.cdata.length > 0);
		
		if((child.children.length > 1 && hasCDATA) || (child.children.length == 0 && !hasCDATA)) {
			context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_NODE_OR_CDATA));
			return null;
		}

		var matchResult = matchValue(context, scope, child);
		if(matchResult != null) {
			rememberProperty(context, scope, child.name.localPart, matchResult);
		}
		return matchResult;
	}
	
	function matchValue(context : HxmrContext, scope:NodeScope, child:MXMLNode) : IInitializator {

		if(child.cdata != null && child.cdata.length > 0) {
			return InitBinding(new BindingInitializator(null, child.cdata));
		}

		// TODO ArrayInitializers
		if(child.children.length > 1) {
			context.error(new PropertiesAnalyzerError(VALUE_MUST_BE_ONE_NODE));
			return null;
		}
		
		if(child.children.length == 0) {
			return null;
		}
		
		var innerChild : MXMLNode = child.children[0];
		
		var qName : QName = scope.context.resolveQName(innerChild.name);

		var id = scope.getNodeId(innerChild);
		
		var initializator : FieldInitializator = switch(qName.toHaxeTypeId()) {
				
			case "String", "Int", "Float":
				new FieldInitializator(id, innerChild.cdata, scope.context.getType(qName));
			
			case "Array":
				var childs : Array<IInitializator> = [];
			
				for(child in innerChild.children) {
					var childScope : NodeScope = analyzer.analyze(context, child, scope);
					var value = InitField(new FieldInitializator(scope.getFieldNameForNode(child), childScope, childScope.type));
					if(value != null) {
						childs.push(value);
					} else {
						trace("value null for child: " + child);
					}
				}

				new FieldInitializator(scope.getFieldNameForNode(innerChild), childs, Context.getType("Array"));
			
			case type:
				trace("_ " + type);
				var childScope : NodeScope = analyzer.analyze(context, innerChild, scope);

				if(childScope == null) {
					//TODO logging?
					trace("childScope is null");
					return null;
				}
				new FieldInitializator(scope.getFieldNameForNode(innerChild), childScope, childScope.type);
		}
		
		return id == null ? InitBinding(initializator) : InitField(initializator);
	}

	function rememberProperty(context : HxmrContext, scope : NodeScope, fieldName : String, value:IInitializator) : Void {

		if(scope.initializers.exists(fieldName)) {
			context.error(new PropertiesAnalyzerError(DUPLICATE));
			return;
		}

		scope.initializers.set(fieldName, value);
	}

	function getInitializatorFieldName(value:IInitializator) : String {
		return switch(value) {
			case InitBinding(bindingInitializator): bindingInitializator.fieldName;
			case InitField(nodeInitializator): nodeInitializator.fieldName;
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

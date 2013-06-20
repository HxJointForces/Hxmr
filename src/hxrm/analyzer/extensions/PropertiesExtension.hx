package hxrm.analyzer.extensions;
import hxrm.HxmrContext.FilePos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import haxe.macro.Type.ClassField;
import hxrm.analyzer.initializers.NodeScopeInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

enum PropertiesAnalyzerErrorType {
	UNKNOWN_FIELD;
	VALUE_MUST_BE_ONE_NODE;
	ATTRIBUTES_IN_PROPERTY;
	DUPLICATE;
}

class PropertiesAnalyzerError extends NodeAnalyzerError {
	public var type : PropertiesAnalyzerErrorType;

	public function new(type : PropertiesAnalyzerErrorType, ?pos : FilePos) {
		super(pos);
		this.type = type;
	}
}

class PropertiesExtension extends NodeAnalyzerExtensionBase {

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
		
		if(scope.getFieldByName(attributeQName.localPart) == null) {
			context.error(new PropertiesAnalyzerError(PropertiesAnalyzerErrorType.UNKNOWN_FIELD));
			return;
		}
		
		rememberProperty(context, scope, attributeQName, new BindingInitializator(value));
	}

	function matchChild(context : HxmrContext, scope:NodeScope, child:MXMLNode):Void {
	
		if(child.name.namespace != scope.context.node.name.namespace) {
			return;
		}

		// TODO ArrayInitializers
		if(child.children.length > 1 || (child.cdata != null && child.cdata.length > 0)) {
			context.error(new PropertiesAnalyzerError(PropertiesAnalyzerErrorType.VALUE_MUST_BE_ONE_NODE));
			return;
		}
		
		if(child.attributes.iterator().hasNext()) {
			context.error(new PropertiesAnalyzerError(PropertiesAnalyzerErrorType.ATTRIBUTES_IN_PROPERTY));
			return;
		}

		if(scope.getFieldByName(child.name.localPart) == null) {
			context.error(new PropertiesAnalyzerError(PropertiesAnalyzerErrorType.UNKNOWN_FIELD));
			return;
		}
		
		var childScope : NodeScope = analyzer.analyze(context, child.children[0]);

		if(childScope == null) {
			//TODO logging?
			trace("childScope is null");
			return;
		}
		
		rememberProperty(context, scope, child.name, new NodeScopeInitializator(childScope));
	}

	function rememberProperty(context : HxmrContext, scope : NodeScope, attributeQName:MXMLQName, value:IInitializator) : Void {

		if(scope.initializers.exists(attributeQName.localPart)) {
			context.error(new PropertiesAnalyzerError(PropertiesAnalyzerErrorType.DUPLICATE));
			return;
		}

		scope.initializers.set(attributeQName.localPart, value);
	}
}

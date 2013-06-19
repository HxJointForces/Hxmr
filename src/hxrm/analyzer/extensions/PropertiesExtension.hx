package hxrm.analyzer.extensions;
import haxe.macro.Type.ClassField;
import hxrm.analyzer.initializers.NodeScopeInitializator;
import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

class PropertiesExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(scope:NodeScope):Bool {
	
		if(scope.initializers == null) {
			scope.initializers = new Map();
		}
	
		var node : MXMLNode = scope.context.node;
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(scope, attributeQName, value);
		}
		
		for (childNode in node.children) {
			matchChild(scope, childNode);
		}

		return false;
	}

	function matchAttribute(scope:NodeScope, attributeQName:MXMLQName, value:String):Void {

		if(attributeQName.namespace != scope.context.node.name.namespace && attributeQName.namespace != MXMLQName.ASTERISK) {
			return;
		}
		
		if(scope.getFieldByName(attributeQName.localPart) == null) {
			throw "unknown field!";
		}
		
		rememberProperty(scope, attributeQName, new BindingInitializator(value));
	}

	function matchChild(scope:NodeScope, child:MXMLNode):Void {
	
		if(child.name.namespace != scope.context.node.name.namespace) {
			return;
		}

		// TODO ArrayInitializers
		if(child.children.length > 1 || (child.cdata != null && child.cdata.length > 0)) {
			throw "value must be exactly one node";
		}
		
		if(child.attributes.iterator().hasNext()) {
			throw "property node can't have attributes";
		}

		if(scope.getFieldByName(child.name.localPart) == null) {
			throw "unknown field: " + child.name.localPart;
		}
		
		var childScope : NodeScope = analyzer.analyze(child.children[0]);

		if(childScope == null) {
			trace("childScope is null");
			return;
		}
		
		rememberProperty(scope, child.name, new NodeScopeInitializator(childScope));
	}

	function rememberProperty(scope : NodeScope, attributeQName:MXMLQName, value:IInitializator) : Void {
		//trace('${attributeQName.localPart} = $value');

		if(scope.initializers.exists(attributeQName.localPart)) {
			trace("duplicate property assign!");
			throw "duplicate property assign!";
		}

		scope.initializers.set(attributeQName.localPart, value);
	}
}

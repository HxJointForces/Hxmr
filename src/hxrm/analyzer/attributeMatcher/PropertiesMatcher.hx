package hxrm.analyzer.attributeMatcher;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

class PropertiesMatcher extends AttributeMatcherBase {

	public function new(analyzer : NodeAnalyzer) {
		super(analyzer);
	}

	override public function match(scope:NodeScope, attributeQName:MXMLQName, value:String):Void {
	
		if(attributeQName.namespace == scope.context.node.name.namespace) {
			trace('${attributeQName.localPart} = $value');
			
			if(scope.initializers.exists(attributeQName.localPart)) {
				trace("duplicate property assign!");
				throw "duplicate property assign!";
			}
			
			scope.initializers.set(attributeQName.localPart, value);
		}
		else {
			super.match(scope, attributeQName, value);
		}
	}
}

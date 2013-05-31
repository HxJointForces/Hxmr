package hxrm.analyzer.attributeMatcher;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
class PropertiesMatcher extends AttributeMatcherBase {
	public function new() {
		super();
	}

	override public function matchAttribute(attributeQName:MXMLQName, value:String, context : AnalyzerContext, scope:NodeScope):Void {
	
		if(attributeQName.namespace == context.node.name.namespace) {
			trace('${attributeQName.localPart} = $value');
			
			scope.initializers.set(attributeQName.localPart, value);
		}
		else {
			super.matchAttribute(attributeQName, value, context, scope);
		}
	}


}

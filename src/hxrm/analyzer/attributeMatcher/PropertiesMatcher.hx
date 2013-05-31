package hxrm.analyzer.attributeMatcher;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
class PropertiesMatcher extends AttributeMatcherBase {
	public function new() {
		super();
	}

	override public function matchAttribute(attributeQName:MXMLQName, value:String, node:MXMLNode, scope:NodeScope):Void {
		return switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "*", _ ]:
				trace('${attributeQName.localPart} = $value');
				true;

			case _:
				super.matchAttribute(attributeQName, value, node, scope);
		}
	}


}

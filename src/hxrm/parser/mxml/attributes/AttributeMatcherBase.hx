package hxrm.parser.mxml.attributes;
class AttributeMatcherBase implements IAttributeMatcher {
	public function new() {
	}

	public function matchAttribute(attributeQName : QName, value : String, n : MXMLNode) : Bool {
		return false;
	}
}

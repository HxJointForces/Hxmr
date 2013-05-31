package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;
class AttributeMatcherBase implements IAttributeMatcher {
	public function new() {
	}

	public function matchAttribute(attributeQName : QName, value : String, n : MXMLNode, scope : NodeScope) : Bool {
		return false;
	}
}

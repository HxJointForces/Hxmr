package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
class AttributeMatcherBase implements IAttributeMatcher {
	public function new() {
	}

	public function matchAttribute(attributeQName : MXMLQName, value : String, node : MXMLNode, scope : NodeScope) : Bool {
		return false;
	}
}

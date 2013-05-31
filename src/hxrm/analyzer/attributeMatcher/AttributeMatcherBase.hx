package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
class AttributeMatcherBase implements IAttributeMatcher {
	public function new() {
	}

	public function match(scope : NodeScope, attributeQName : MXMLQName, value : String) : Void {
	}
}

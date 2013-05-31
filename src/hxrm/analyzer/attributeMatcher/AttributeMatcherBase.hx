package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
class AttributeMatcherBase implements IAttributeMatcher {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function match(scope : NodeScope, attributeQName : MXMLQName, value : String) : Void {
	}
}

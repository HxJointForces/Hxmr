package hxrm.analyzer.childrenMatcher;

import hxrm.parser.mxml.MXMLNode;

class ChildrenMatcherBase implements IChildrenMatcher {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function match(scope : NodeScope, child : MXMLNode) : Void {
	}
}

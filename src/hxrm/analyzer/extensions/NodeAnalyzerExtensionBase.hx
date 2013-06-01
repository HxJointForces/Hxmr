package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
class NodeAnalyzerExtensionBase implements INodeAnalyzerExtension {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function analyze(scope:NodeScope):Bool {
		return false;
	}
}

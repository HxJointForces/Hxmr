package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
class NodeAnalyzerExtensionBase implements INodeAnalyzerExtension {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function matchAttribute(scope : NodeScope, attributeQName : MXMLQName, value : String) : Bool {
		return false;
	}

	public function matchChild(scope : NodeScope, child : MXMLNode) : Bool {
		return false;
	}
}

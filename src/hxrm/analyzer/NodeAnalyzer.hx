package hxrm.analyzer;
import hxrm.parser.mxml.MXMLNode;
class NodeAnalyzer {
	public function new() {
	}

	public function analyze(node : MXMLNode) : NodeScope
	{
		return new NodeScope(node);
	}
}

package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;

class NodeAnalyzerExtensionBase implements INodeAnalyzerExtension {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		return false;
	}
}

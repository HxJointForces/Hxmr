package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;

class NodeAnalyzerExtensionBase implements INodeAnalyzerExtension {

	public function new() {
	}

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		return false;
	}
}

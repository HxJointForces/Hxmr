package hxrm.analyzer.extensions;

class NodeAnalyzerExtensionBase implements INodeAnalyzerExtension {

	var analyzer : NodeAnalyzer;

	public function new(analyzer : NodeAnalyzer) {
		this.analyzer = analyzer;
	}

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		return false;
	}
}

package hxrm.analyzer;

import hxrm.analyzer.extensions.INodeAnalyzerExtension;
import hxrm.parser.mxml.MXMLNode;
import hxrm.HxmrContext;


class NodeAnalyzerError extends ContextError {
}

class NodeAnalyzer {

	public function new() {
	}

	public function analyze(context : HxmrContext, node : MXMLNode, ?parentScope : NodeScope) : NodeScope
	{
		var result : NodeScope = new NodeScope();
		result.parentScope = parentScope;

		result.context = new AnalyzerContext(node);
		
		var currentIterationExtensions = context.analyzerExtensions.iterator();

		while(currentIterationExtensions.hasNext()) {
			var nextIterationExtensions : Array<INodeAnalyzerExtension> = [];
			
			for(extension in currentIterationExtensions) {
				if(extension.analyze(context, result)) {
					nextIterationExtensions.push(extension);
				}
			}
			currentIterationExtensions = nextIterationExtensions.iterator();
		}
		
		return result;
	}
}

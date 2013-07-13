package hxrm.analyzer;

import hxrm.extensions.base.IHxmrExtension;
import hxrm.extensions.base.INodeAnalyzerExtension;
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
		
		var currentIterationExtensions = context.extensions.iterator();

		while(currentIterationExtensions.hasNext()) {
			var nextIterationExtensions : Array<IHxmrExtension> = [];
			
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

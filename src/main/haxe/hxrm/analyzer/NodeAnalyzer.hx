package hxrm.analyzer;

import hxrm.analyzer.extensions.DeclarationsAnalyzerExtension;
import hxrm.analyzer.extensions.GenericTypeExtension;
import hxrm.analyzer.extensions.ChildrenAnalyzerExtension;
import hxrm.analyzer.extensions.ScriptBlockExtension;
import hxrm.analyzer.extensions.PropertiesAnalyzerExtension;
import hxrm.analyzer.extensions.TypeExtension;
import hxrm.analyzer.extensions.INodeAnalyzerExtension;
import hxrm.parser.mxml.MXMLNode;
import hxrm.HxmrContext;


class NodeAnalyzerError extends ContextError {
}

class NodeAnalyzer {

	private var extensions : Array<INodeAnalyzerExtension>;

	public function new() {
		extensions = [];
        extensions.push(new TypeExtension(this));
        extensions.push(new PropertiesAnalyzerExtension(this));
        extensions.push(new ScriptBlockExtension(this));
        extensions.push(new ChildrenAnalyzerExtension(this));
        extensions.push(new GenericTypeExtension(this));
        extensions.push(new DeclarationsAnalyzerExtension(this));
	}

	public function analyze(context : HxmrContext, node : MXMLNode, ?parentScope : NodeScope) : NodeScope
	{
		var result : NodeScope = new NodeScope();
		result.parentScope = parentScope;

		result.context = new AnalyzerContext(node);
		
		var currentIterationExtensions = extensions;

		while(currentIterationExtensions.length != 0) {
			var nextIterationExtensions : Array<INodeAnalyzerExtension> = [];
			
			for(extension in currentIterationExtensions) {
				if(extension.analyze(context, result)) {
					nextIterationExtensions.push(extension);
				}
			}
			currentIterationExtensions = nextIterationExtensions;
		}
		
		return result;
	}
}

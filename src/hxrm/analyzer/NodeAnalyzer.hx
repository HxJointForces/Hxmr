package hxrm.analyzer;

import hxrm.analyzer.extensions.GenericTypeExtension;
import hxrm.analyzer.extensions.ChildrenExtension;
import hxrm.analyzer.extensions.ScriptBlockExtension;
import hxrm.analyzer.extensions.PropertiesExtension;
import hxrm.analyzer.extensions.TypeExtension;
import hxrm.analyzer.extensions.INodeAnalyzerExtension;
import hxrm.parser.mxml.MXMLNode;
import hxrm.HxmrContext;


class NodeAnalyzerError extends ContextError {
}

class NodeAnalyzer {

	private var extensions : Array<INodeAnalyzerExtension>;

	public function new() {
		extensions = [new TypeExtension(this), new PropertiesExtension(this), new ScriptBlockExtension(this), new ChildrenExtension(this), new GenericTypeExtension(this)];
	}

	public function analyze(context : HxmrContext, node : MXMLNode) : NodeScope
	{
		var result : NodeScope = new NodeScope();

		result.context = new AnalyzerContext(node);

		while(true) {
			var oneMoreTime : Bool = false;
			
			for(extension in extensions) {
				oneMoreTime = extension.analyze(context, result) || oneMoreTime;
			}
			
			if(!oneMoreTime) {
				break;
			}
		}
		
		return result;
	}
}

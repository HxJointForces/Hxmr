package hxrm.analyzer;

import hxrm.analyzer.extensions.DefaultPropertyExtension;
import hxrm.analyzer.extensions.ScriptBlockExtension;
import hxrm.analyzer.extensions.PropertiesExtension;
import hxrm.parser.mxml.MXMLQName;
import StringTools;
import hxrm.analyzer.extensions.TypeExtension;
import hxrm.analyzer.extensions.INodeAnalyzerExtension;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {

	private var extensions : Array<INodeAnalyzerExtension>;

	public function new() {
		extensions = [new TypeExtension(this), new PropertiesExtension(this), new ScriptBlockExtension(this), new DefaultPropertyExtension(this)];
	}

	public function analyze(node : MXMLNode) : NodeScope
	{
		var result : NodeScope = new NodeScope();

		result.context = new AnalyzerContext(node);

		while(true) {
			var oneMoreTime : Bool = false;
			
			for(extension in extensions) {
				oneMoreTime = extension.analyze(result, node) || oneMoreTime;
			}
			
			if(!oneMoreTime) {
				break;
			}
		}
		
		return result;
	}
}

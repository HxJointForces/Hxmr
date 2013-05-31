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
		// TODO namespaces from parent node
		var resolvedQName : QName = result.context.resolveQName(node.name, node);

		result.type = result.context.getType(resolvedQName);

		while(true) {
			var oneMoreTime : Bool = false;
			for (attributeQName in node.attributes.keys()) {
				var value : String = node.attributes.get(attributeQName);
				for(attributeMatcher in extensions) {
					oneMoreTime = attributeMatcher.matchAttribute(result, attributeQName, value) || oneMoreTime;
				}
			}
			if(!oneMoreTime) {
				break;
			}
		}

		result.classType = result.context.getClassType(result.type);

		result.fields = result.classType.fields.get();

		for (childNode in node.children) {
			for(childrenMatcher in extensions) {
				childrenMatcher.matchChild(result, childNode);
			}
		}

		if (result.classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "can't instantiate interface " + resolvedQName;
		}

		if (result.classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "can't instantiate private class " + resolvedQName;
		}
		
		return result;
	}
}

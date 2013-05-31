package hxrm.analyzer;
import hxrm.analyzer.attributeMatcher.PropertiesMatcher;
import hxrm.parser.mxml.MXMLQName;
import StringTools;
import hxrm.analyzer.attributeMatcher.GenericAttributeMatcher;
import hxrm.analyzer.attributeMatcher.IAttributeMatcher;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {

	private var matchers : Array<IAttributeMatcher>;

	public function new() {
		matchers = [new GenericAttributeMatcher(), new PropertiesMatcher()];
	}

	public function analyze(node : MXMLNode, ?parentNode : MXMLNode, ?parent:NodeScope) : NodeScope
	{
		var result : NodeScope = new NodeScope();


		result.context = new AnalyzerContext(node);
		
		// namespaces тоже надо в скопе держать, т.к. у вложенных нодов их нужно 
		// объединять с текущими неймспейсами
		// <A xmlns:a="a">  // namespaces = [a=>a];
		//    <B xmlns:b="b"/>  // namespaces = [a=>a, b=>b]
		// </A>
		// т.е. я предполагал делать новый скоп для каждого дочернего нода
		// SergeiEgorov: как раз таки нет:) В процессе анализа неймспейсы уйдут
		//var namespaces : Map < String, Array<String> > = new Map();

		result.parentScope = parent;
		if (result.parentScope != null) result.copyFrom(result.parentScope);

		// TODO namespaces from parent node
		var resolvedQName : QName = result.context.resolveClassPath(node.name, node.namespaces);
		result.type = result.context.getType(resolvedQName);
		result.classType = result.context.getClassType(result.type);

		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			for(attributeMatcher in matchers) {
				attributeMatcher.matchAttribute(attributeQName, value, result.context, result);
			}
		}

		// Checks
		
		if (result.classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "can't instantiate interface " + resolvedQName;
		}

		if (result.classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "can't instantiate private class " + resolvedQName;
		}

		result.fields = result.classType.fields.get();
		
		return result;
	}
}

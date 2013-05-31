package hxrm.analyzer;

import hxrm.analyzer.childrenMatcher.ScriptBlockChildrenMatcher;
import hxrm.analyzer.childrenMatcher.IChildrenMatcher;
import hxrm.analyzer.attributeMatcher.PropertiesMatcher;
import hxrm.parser.mxml.MXMLQName;
import StringTools;
import hxrm.analyzer.attributeMatcher.GenericAttributeMatcher;
import hxrm.analyzer.attributeMatcher.IAttributeMatcher;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {

	private var attributeMatchers : Array<IAttributeMatcher>;
	private	var childrenMatchers : Array<IChildrenMatcher>;

	public function new() {
		attributeMatchers = [new GenericAttributeMatcher(), new PropertiesMatcher()];
		childrenMatchers = [new ScriptBlockChildrenMatcher()];
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
		var resolvedQName : QName = result.context.resolveQName(node.name, node);
		result.type = result.context.getType(resolvedQName);
		result.classType = result.context.getClassType(result.type);
		result.fields = result.classType.fields.get();

		if (result.classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "can't instantiate interface " + resolvedQName;
		}

		if (result.classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "can't instantiate private class " + resolvedQName;
		}

		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			for(attributeMatcher in attributeMatchers) {
				attributeMatcher.match(result, attributeQName, value);
			}
		}

		for (childNode in node.children) {
			for(childrenMatcher in childrenMatchers) {
				childrenMatcher.match(result, childNode);
			}
		}
		
		return result;
	}
}

package hxrm.analyzer;

import hxrm.analyzer.extensions.DefaultPropertyExtension;
import hxrm.analyzer.extensions.ScriptBlockExtension;
import hxrm.analyzer.extensions.PropertiesExtension;
import hxrm.parser.mxml.MXMLQName;
import StringTools;
import hxrm.analyzer.extensions.GenericExtension;
import hxrm.analyzer.extensions.INodeAnalyzerExtension;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {

	private var extensions : Array<INodeAnalyzerExtension>;

	public function new() {
		extensions = [new GenericExtension(this), new PropertiesExtension(this), new ScriptBlockExtension(this), new DefaultPropertyExtension(this)];
	}

	public function analyze(node : MXMLNode) : NodeScope
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

		// TODO namespaces from parent node
		var resolvedQName : QName = result.context.resolveQName(node.name, node);
		result.type = result.context.getType(resolvedQName);
		
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			new GenericExtension(this).matchAttribute(result, attributeQName, value);
		}
		trace(result.typeParams);
			
		var genericTypes = [];
		for (genericType in result.typeParams) {
			genericTypes.push(Context.getType(genericType.toHaxeTypeId()));
		}
		trace(genericTypes);
		
		switch (result.type) {
			case TInst(t, _): result.type = TInst(t, genericTypes);
			case _: throw "assert";
		}
		
		trace(result.type);
		
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
			for(attributeMatcher in extensions) {
				attributeMatcher.matchAttribute(result, attributeQName, value);
			}
		}

		for (childNode in node.children) {
			for(childrenMatcher in extensions) {
				childrenMatcher.matchChild(result, childNode);
			}
		}
		
		return result;
	}
}

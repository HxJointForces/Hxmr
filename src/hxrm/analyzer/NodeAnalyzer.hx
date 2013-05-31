package hxrm.analyzer;
import StringTools;
import hxrm.analyzer.attributeMatcher.GenericAttributeMatcher;
import hxrm.analyzer.attributeMatcher.IAttributeMatcher;
import hxrm.utils.QNameUtils;
import hxrm.parser.QName;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {

	private var matchers : Array<IAttributeMatcher>;

	public function new() {
		matchers = [new GenericAttributeMatcher()];
	}

	public function analyze(node : MXMLNode, ?parent:NodeScope) : NodeScope
	{
		var result : NodeScope = new NodeScope();
		
		// namespaces тоже надо в скопе держать, т.к. у вложенных нодов их нужно 
		// объединять с текущими неймспейсами
		// <A xmlns:a="a">  // namespaces = [a=>a];
		//    <B xmlns:b="b"/>  // namespaces = [a=>a, b=>b]
		// </A>
		// т.е. я предполагал делать новый скоп для каждого дочернего нода
		// SergeiEgorov: как раз таки нет:) В процессе анализа неймспейсы уйдут
		var namespaces : Map < String, Array<String> > = new Map();

		result.parentScope = parent;
		if (result.parentScope != null) result.copyFrom(result.parentScope);

		for (nsName in node.namespaces.keys()) {
			namespaces[nsName] = QNameUtils.splitNamespace(node.namespaces[nsName]);
		}

		var resolvedQName : QName = resolveClassPath(node.name, namespaces);
		result.type = getType(resolvedQName);
		result.classType = getClassType(result.type);

		for (attributeQName in node.attributes.keys()) {
			var matched = false;
			var value : String = node.attributes.get(attributeQName);
			for(attributeMatcher in matchers) {
				matched = attributeMatcher.matchAttribute(attributeQName, value, node, result);
			}
			if(!matched) {
				//TODO this is a field setter
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

		var r = ~/(.*?=>.*?),/g; // g : replace all instances
		var classTypeAsString : String = Std.string(result.classType);
		classTypeAsString = r.replace(classTypeAsString, "$1,\n\t");
		trace("ClassType " + classTypeAsString.split("{").join("{\n\t").split("}").join("\n}\n"));

		result.fields = result.classType.fields.get();
		
		return result;
	}
	
	public inline function getClassType(type : Type) : ClassType {
		return switch (type) {
			case TInst(t, params):
				t.get();
			case _:
				trace("unsupported type: " + type);
				throw "unsupported type: " + type;
		}
	}

	public function getType(typeQName:QName):Type {
		var type = null;
		try {
			type = Context.getType(typeQName.toHaxeTypeId());
		} catch (e:Dynamic) {
			trace(e);
			throw "can't find type: " + typeQName;
		}
		return type;
	}

	public function resolveClassPath(q:QName, namespaces : Map<String, Array<String>>):QName {

		if (!namespaces.exists(q.namespace)) throw "unknow namespace";
		var resolvedNamespaceParts : Array<String> = namespaces[q.namespace];

		// <flash.display.Sprite /> support
		var localQName : QName = QNameUtils.fromHaxeTypeId(q.localPart);

		var localQNameParts : Array<String> = QNameUtils.splitNamespace(localQName.namespace);
		// concat return new array
		//TODO Namespace.isNotEmpty method
		if(localQNameParts.length > 0 && localQNameParts[0] != QName.ASTERISK) {
			resolvedNamespaceParts = resolvedNamespaceParts.concat(localQNameParts);
		}

		return new QName(QNameUtils.joinNamespaceParts(resolvedNamespaceParts), localQName.localPart);
	}
}

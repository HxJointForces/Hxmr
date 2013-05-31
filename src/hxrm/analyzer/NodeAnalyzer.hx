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
		var resolvedQName : QName = resolveClassPath(node.name, node.namespaces);
		result.type = getType(resolvedQName);
		result.classType = getClassType(result.type);

		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			for(attributeMatcher in matchers) {
				attributeMatcher.matchAttribute(attributeQName, value, node, result);
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

		var r = ~/(.*?=>.*?), /g; // g : replace all instances
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

	public function resolveClassPath(node:MXMLQName, namespaces : Map<String, String>):QName {

		if (!namespaces.exists(node.namespace)) throw "unknow namespace";
		var resolvedPackageNameParts : Array<String> = QNameUtils.splitPackage(namespaces[node.namespace]);
		
		if(resolvedPackageNameParts != null && resolvedPackageNameParts.length > 0) {
			if(resolvedPackageNameParts[resolvedPackageNameParts.length - 1] == MXMLQName.ASTERISK) {
				resolvedPackageNameParts.pop();
			}
		}
		
		// <flash.display.Sprite /> support
		var localQName : QName = QNameUtils.fromHaxeTypeId(node.localPart);

		// concat return new array
		//TODO Namespace.isNotEmpty method
		if(QNameUtils.packageNameIsEmpty(localQName.packageNameParts)) {
			resolvedPackageNameParts = resolvedPackageNameParts.concat(localQName.packageNameParts);
		}

		return new QName(resolvedPackageNameParts, localQName.className);
	}
}

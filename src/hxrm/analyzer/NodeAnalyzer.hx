package hxrm.analyzer;
import hxrm.utils.QNameUtils;
import hxrm.parser.QName;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {
	public function new() {
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
		var namespaces : Map < String, Array<String> > = new Map();

		result.typeParams = node.typeParams;
		result.parentScope = parent;
		if (result.parentScope != null) result.copyFrom(result.parentScope);

		for (nsName in node.namespaces.keys()) {
			namespaces[nsName] = QNameUtils.splitNamespace(node.namespaces[nsName]);
		}

		var resolvedQName : QName = resolveClassPath(node.name, namespaces);
		result.type = getType(resolvedQName);
		result.classType = getClassType(result.type);

		// Checks
		switch (result.type) {
			case TInst(t, params):
				if (params.length != node.typeParams.length) {
					trace("incorect type params count");
					throw "incorect type params count";
				}
			case _:
		}

		if (result.classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "";
		}

		if (result.classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "";
		}
		
		trace(result.classType);

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

		// concat return new array
		resolvedNamespaceParts = resolvedNamespaceParts.concat(QNameUtils.splitNamespace(localQName.namespace));

		return new QName(QNameUtils.joinNamespaceParts(resolvedNamespaceParts), localQName.localPart);
	}
}

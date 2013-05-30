package hxrm.analyzer;
import hxrm.utils.QNameUtils;
import hxrm.parser.QName;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Context;
import haxe.macro.Type;

class NodeAnalyzer {
	public function new() {
	}

	public function analyze(n : MXMLNode, ?parent:NodeScope) : NodeScope
	{
		var result : NodeScope = new NodeScope();

		result.typeParams = n.typeParams;
		result.namespaces = new Map();
		result.parentScope = parent;
		if (result.parentScope != null) result.copyFrom(result.parentScope);

		for (nsName in n.namespaces.keys()) {
			result.namespaces[nsName] = QNameUtils.splitNamespace(n.namespaces[nsName]);
		}

		var resolvedQName : QName = resolveClassPath(n.name, result.namespaces);
		result.type = getType(resolvedQName);
		switch (result.type) {
			case TInst(t, params):
				if (params.length != n.typeParams.length) {
					trace("incorect type params count");
					throw "incorect type params count";
				}
				result.classType = t.get();
			case _:
				trace("unsupported type: " + result.type);
				throw "unsupported type: " + result.type;
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
		result.statics = result.classType.statics.get();
		
		return result;
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

		resolvedNamespaceParts.concat(QNameUtils.splitNamespace(localQName.namespace));

		return new QName(QNameUtils.joinNamespaceParts(resolvedNamespaceParts), localQName.localPart);
	}
}

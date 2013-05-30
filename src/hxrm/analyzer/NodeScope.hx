package hxrm.analyzer;

import hxrm.utils.QNameUtils;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;

using StringTools;
using haxe.macro.Tools;

class NodeScope {

	public var namespaces:Map < String, Array<String> > ;

	public var typeParams:Array<QName>;

	public var type:Type;
	public var classType:ClassType;

	public var fields:Array<ClassField>;
	public var statics:Array<ClassField>;

	public var parentScope:NodeScope;

	public function new(n:MXMLNode, ?parent:NodeScope) {

		typeParams = n.typeParams;
		namespaces = new Map();
		parentScope = parent;
		if (parentScope != null) copyFrom(parentScope);

		for (nsName in n.namespaces.keys()) {
			namespaces[nsName] = QNameUtils.splitNamespace(n.namespaces[nsName]);
		}

		var resolvedQName : QName = resolveClassPath(n.name);
		type = getType(resolvedQName);
		switch (type) {
			case TInst(t, params):
				if (params.length != n.typeParams.length) {
					trace("incorect type params count");
					throw "incorect type params count";
				}
				classType = t.get();
			case _:
				trace("unsupported type: " + type);
				throw "unsupported type: " + type;
		}

		if (classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "";
		}

		if (classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "";
		}

		trace(classType);

		fields = classType.fields.get();
		statics = classType.statics.get();
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

	function resolveClassPath(q:QName):QName {

		if (!namespaces.exists(q.namespace)) throw "unknow namespace";
		var resolvedNamespaceParts : Array<String> = namespaces[q.namespace];

		// <flash.display.Sprite /> support
		var localQName : QName = QNameUtils.fromHaxeTypeId(q.localPart);
		
		resolvedNamespaceParts.concat(QNameUtils.splitNamespace(localQName.namespace));
		
		return new QName(QNameUtils.joinNamespaceParts(resolvedNamespaceParts), localQName.localPart);
	}

	public function copyFrom(s:NodeScope):Void {
		for (nsName in s.namespaces.keys()) {
			namespaces[nsName] = s.namespaces[nsName];
		}
	}
}
package hxrm.analyzer;
import hxrm.utils.QNameUtils;
import hxrm.parser.QName;
import hxrm.parser.mxml.MXMLNode;

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

		var resolvedQName : QName = result.resolveClassPath(n.name);
		result.type = result.getType(resolvedQName);
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
}

package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
import haxe.macro.Context;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TypeExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(scope:NodeScope, node:MXMLNode):Bool {

		var resolvedQName : QName = scope.context.resolveQName(node.name, node);

		scope.type = scope.context.getType(resolvedQName);
		scope.classType = scope.context.getClassType(scope.type);
		scope.fields = scope.classType.fields.get();

		if (scope.classType.isInterface) {
			trace("can't instantiate interface " + resolvedQName);
			throw "can't instantiate interface " + resolvedQName;
		}

		if (scope.classType.isPrivate) {
			trace("can't instantiate private class " + resolvedQName);
			throw "can't instantiate private class " + resolvedQName;
		}
		
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(scope, attributeQName, value);
		}
		
		return false;
	}

	function matchAttribute(scope : NodeScope, attributeQName:MXMLQName, value:String):Void {
		switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "generic", "type" ]:
			
				var typeParams = value.split(",").map(QNameUtils.fromHaxeTypeId);
				switch (scope.type) {
					case TInst(t, params):
						if (params.length != typeParams.length) {
							trace("incorect type params count");
							throw "incorect type params count";
						}
					case _:
				}

				trace(typeParams);

				var genericTypes = [];
				for (genericType in typeParams) {
					genericTypes.push(Context.getType(genericType.toHaxeTypeId()));
				}
				trace(genericTypes);

				switch (scope.type) {
					case TInst(t, _): scope.type = TInst(t, genericTypes);
					case _: throw "assert";
				}
			case _:
		}
	}
	
}
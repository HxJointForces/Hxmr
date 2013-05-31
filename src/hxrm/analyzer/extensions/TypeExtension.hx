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

	override public function matchAttribute(scope : NodeScope, attributeQName:MXMLQName, value:String):Bool {
		return switch [attributeQName.namespace, attributeQName.localPart] {
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
				false;
			case _:
				super.matchAttribute(scope, attributeQName, value);
		}
	}
	
}
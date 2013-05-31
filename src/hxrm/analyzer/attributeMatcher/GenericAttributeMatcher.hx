package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class GenericAttributeMatcher extends AttributeMatcherBase {

	public function new() {
	}
	
	override public function match(scope : NodeScope, attributeQName:MXMLQName, value:String):Void {
		switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "generic", "type" ]:
				scope.typeParams = value.split(",").map(QNameUtils.fromHaxeTypeId);
				switch (scope.type) {
					case TInst(t, params):
						if (params.length != scope.typeParams.length) {
							trace("incorect type params count");
							throw "incorect type params count";
						}
					case _:
				}

			case _:
				super.match(scope, attributeQName, value);
		}
	}
	
}
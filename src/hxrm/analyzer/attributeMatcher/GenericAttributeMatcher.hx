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
		super();
	}
	
	override public function matchAttribute(attributeQName:MXMLQName, value:String, node:MXMLNode, scope : NodeScope):Void {
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
				super.matchAttribute(attributeQName, value, node, scope);
		}
	}
	
}
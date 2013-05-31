package hxrm.analyzer.attributeMatcher;

import hxrm.utils.QNameUtils;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class GenericAttributeMatcher extends AttributeMatcherBase implements IAttributeMatcher {

	public function new() {
		super();
	}
	
	override public function matchAttribute(attributeQName:QName, value:String, n:MXMLNode, scope : NodeScope):Bool {
		return switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "generic", "type" ]:
				var typeParams : Array<QName> = value.split(",").map(QNameUtils.fromHaxeTypeId);
				switch (scope.type) {
					case TInst(t, params):
						if (params.length != typeParams.length) {
							trace("incorect type params count");
							throw "incorect type params count";
						}
						scope.typeParams = typeParams;
					case _:
				}
				true;

			case _:
				super.matchAttribute(attributeQName, value, n, scope);
		}
	}
	
}
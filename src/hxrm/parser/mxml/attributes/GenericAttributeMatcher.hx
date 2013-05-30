package hxrm.parser.mxml.attributes;

import hxrm.utils.QNameUtils;
import hxrm.parser.mxml.attributes.IAttributeMatcher;
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
	
	override public function matchAttribute(attributeQName:QName, value:String, n:MXMLNode, iterator:Iterator<IAttributeMatcher>):Bool {
		return switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "generic", "type" ]:
				n.typeParams = value.split(",").map(QNameUtils.fromHaxeTypeId);
				true;

			case _:
				super.matchAttribute(attributeQName, value, n, iterator);
		}
	}
	
}
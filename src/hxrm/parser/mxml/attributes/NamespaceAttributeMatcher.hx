package hxrm.parser.mxml.attributes;

class NamespaceAttributeMatcher extends AttributeMatcherBase {

	override public function matchAttribute(attributeQName : QName, value : String, n : MXMLNode, iterator : Iterator<IAttributeMatcher>) : Bool {
		return switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "*", "xmlns" ]:
				n.namespaces["*"] = value;
				true;

			case [ "xmlns", _ ]:
				n.namespaces[attributeQName.localPart] = value;
				true;

			case _:
				super.matchAttribute(attributeQName, value, n, iterator);
		}
	}
}
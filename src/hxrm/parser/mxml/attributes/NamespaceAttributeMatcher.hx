package hxrm.parser.mxml.attributes;

class NamespaceAttributeMatcher extends AttributeMatcherBase {

	override public function matchAttribute(attributeQName : QName, value : String, n : Node, iterator : Iterator<IAttributeMatcher>) : Bool {
		switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "*", "xmlns" ]:
				n.namespaces["*"] = value;
				return true;

			case [ "xmlns", _ ]:
				n.namespaces[attributeQName.localPart] = value;
				return true;

			case _:
				return super.matchAttribute(attributeQName, value, n, iterator);
		}
	}
}
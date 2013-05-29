package hxrm.parser.mxml.attributes;
class AttributeMatcherBase implements IAttributeMatcher {
	public function new() {
	}

	public function matchAttribute(attributeQName : QName, value : String, n : Node, iterator : Iterator<IAttributeMatcher>) : Bool {
		if(!iterator.hasNext()){
			return false;
		}
		return iterator.next().matchAttribute(attributeQName, value, n, iterator);
	}
}

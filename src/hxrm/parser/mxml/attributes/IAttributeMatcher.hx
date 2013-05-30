package hxrm.parser.mxml.attributes;

interface IAttributeMatcher {
	function matchAttribute(attributeQName : QName, value : String, n : MXMLNode) : Bool;
}

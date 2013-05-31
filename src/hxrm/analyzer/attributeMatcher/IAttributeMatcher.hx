package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;
import hxrm.analyzer.NodeScope;
interface IAttributeMatcher {
	function matchAttribute(attributeQName : QName, value : String, node : MXMLNode, scope : NodeScope) : Bool;
}
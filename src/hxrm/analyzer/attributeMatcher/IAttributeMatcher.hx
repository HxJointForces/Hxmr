package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface IAttributeMatcher {
	function match(scope : NodeScope, attributeQName : MXMLQName, value : String) : Void;
}
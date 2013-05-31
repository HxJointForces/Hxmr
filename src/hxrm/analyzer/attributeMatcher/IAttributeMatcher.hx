package hxrm.analyzer.attributeMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface IAttributeMatcher {
	function matchAttribute(attributeQName : MXMLQName, value : String, context : AnalyzerContext, scope : NodeScope) : Void;
}
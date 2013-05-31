package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface INodeAnalyzerExtension {

	// return true if it needs one more iteration
	function matchAttribute(scope : NodeScope, attributeQName : MXMLQName, value : String) : Bool;

	// return true if it needs one more iteration
	function matchChild(scope : NodeScope, child : MXMLNode) : Bool;
}
package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface INodeAnalyzerExtension {
	function matchAttribute(scope : NodeScope, attributeQName : MXMLQName, value : String) : Void;

	function matchChild(scope : NodeScope, child : MXMLNode) : Void;
}
package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface INodeAnalyzerExtension {

	// return true if it needs one more iteration
	function analyze(scope : NodeScope, node : MXMLNode) : Bool;
}
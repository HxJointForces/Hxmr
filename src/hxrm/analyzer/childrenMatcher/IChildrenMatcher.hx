package hxrm.analyzer.childrenMatcher;

import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;
interface IChildrenMatcher {
	function match(scope : NodeScope, child : MXMLNode) : Void;
}
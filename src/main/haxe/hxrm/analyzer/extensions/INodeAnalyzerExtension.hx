package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;

interface INodeAnalyzerExtension {

	// return true if it needs one more iteration
	function analyze(context : HxmrContext, scope : NodeScope) : Bool;
}
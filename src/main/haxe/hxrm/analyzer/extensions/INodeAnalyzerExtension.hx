package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeScope;
interface INodeAnalyzerExtension {

	// return true if it needs one more iteration
	function analyze(context : HxmrContext, scope : NodeScope) : Bool;
}
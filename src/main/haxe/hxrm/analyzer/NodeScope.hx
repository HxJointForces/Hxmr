package hxrm.analyzer;

import hxrm.analyzer.initializers.NodeScopeInitializator;
import hxrm.analyzer.initializers.IInitializator;
import haxe.macro.Type;

class NodeScope {

	public var context : AnalyzerContext;

	public var type:Type;
	public var classType:ClassType;

	public var classFields:Map<String, ClassField>;

	public var initializers : Array<IInitializator>;
	
	public var children : Array<NodeScopeInitializator>;

	public function new() {
	}

	inline public function getFieldByName(name : String) : ClassField {
		return classFields != null ? classFields.get(name) : null;
	}
}
package hxrm.analyzer;

import hxrm.parser.Tools;
import hxrm.analyzer.initializers.IInitializator;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;

class NodeScope {

	public var context : AnalyzerContext;

	public var type:Type;
	public var classType:ClassType;

	public var classFields:Array<ClassField>;

	public var initializers : Map<String, IInitializator>;
	
	public var children : Array<NodeScope>;

	public function new() {
	}

	public function getFieldByName(name : String) : ClassField {
		if(classFields == null) {
			return null;
		}
		
		for(field in classFields) {
			if(field.name == name) {
				return field;
			}
		}
		return null;
	}
}
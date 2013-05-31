package hxrm.analyzer;

import haxe.ds.HashMap;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import hxrm.parser.mxml.MXMLNode;

using StringTools;
using haxe.macro.Tools;

class NodeScope {

	public var context : AnalyzerContext;

	public var typeParams:Array<QName>;

	public var type:Type;
	public var classType:ClassType;

	public var fields:Array<ClassField>;

	public var parentScope:NodeScope;
	
	public var initializers : Map<String, String>;

	public function new() {
		typeParams = [];
		fields = [];
		initializers = new Map();
	}

	public function copyFrom(s:NodeScope):Void {
		//TODO
	}
}
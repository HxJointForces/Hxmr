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

	public var initializers : Map<String, String>;
	
	public var children : Array<NodeScope>;

	public function new() {
		typeParams = [];
		fields = [];
		children = [];
		initializers = new Map();
	}
}
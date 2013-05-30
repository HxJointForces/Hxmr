package hxrm.analyzer;

import hxrm.utils.QNameUtils;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;

using StringTools;
using haxe.macro.Tools;

class NodeScope {

	public var namespaces:Map < String, Array<String> > ;

	public var typeParams:Array<QName>;

	public var type:Type;
	public var classType:ClassType;

	public var fields:Array<ClassField>;
	public var statics:Array<ClassField>;

	public var parentScope:NodeScope;

	public function new() {
	}

	public function copyFrom(s:NodeScope):Void {
		for (nsName in s.namespaces.keys()) {
			namespaces[nsName] = s.namespaces[nsName];
		}
	}
}
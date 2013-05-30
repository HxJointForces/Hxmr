package hxrm.writer.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.QName;

using StringTools;
using haxe.macro.Tools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TypeDefenitionWriter
{
	
	public function new() 
	{
	}
	
	public function write(n:MXMLNode, type:String, file:String):TypeDefinition {

		trace('write:$type');
		var s = new NodeScope(n);
		trace(s);
		
		var pack = type.split(".");
		var name = pack.pop();
		
		var params = [];
		var fields = [];
		
		return {
			pack: pack,
			name: name,
			pos: Context.makePosition( { min:0, max:0, file:file } ),
			meta: [],
			params: params,
			isExtern: false,
			kind: TDClass(null, null, false),
			fields:fields
		}
	}
	
	public function cleanCache():Void {
		
	}
	
}

class NodeScope {
	
	public var namespaces:Map < String, Array<String> > ;
	
	public var type:Type;
	public var classType:ClassType;
	
	public var fields:Array<ClassField>;
	public var statics:Array<ClassField>;
	
	public var parentScope:NodeScope;
	
	public function new(n:MXMLNode, ?parent:NodeScope) {
		
		namespaces = new Map();
		parentScope = parent;
		if (parentScope != null) copyFrom(parentScope);
		
		for (nsName in n.namespaces.keys()) {
			namespaces[nsName] = parseNamespace(n.namespaces[nsName]);
		}
		
		var cp = resolveClassPath(n.name);
		type = getType(cp.join("."));
		switch (type) {
			case TInst(t, params):
				if (params.length != n.typeParams.length) {
					trace("incorect type params count");
					throw "incorect type params count";
				}
				classType = t.get();
			case _:
				trace("unsupported type: " + type);
				throw "unsupported type: " + type;
		}
		
		if (classType.isInterface) {
			trace("can't instantiate interface " + cp.join("."));
			throw "";
		}
		
		if (classType.isPrivate) {
			trace("can't instantiate private class " + cp.join("."));
			throw "";
		}
		
		trace(classType);
		
		fields = classType.fields.get();
		statics = classType.statics.get();
	}
	
	function getGenericTypes(types:Array<String>):Array<Type> {
		var res = [];
		for (t in types) res.push(getType(t));
		return res;
	}
	
	public function getType(s:String):Type {
		var type = null;
		try {
			type = Context.getType(s);
		} catch (e:Dynamic) {
			trace(e);
			throw "can't find type: " + s;
		}
		return type;
	}
	
	function resolveClassPath(q:QName):Array<String> {
		
		if (!namespaces.exists(q.namespace)) throw "unknow namespace";
		var p = namespaces[q.namespace];
		return 
			if (q.localPart.indexOf(".") != -1) 
				p.concat(q.localPart.split("."));  // <flash.display.Sprite /> support
			else
				p.concat([q.localPart]);
	}
	
	function parseNamespace(value:String):Array<String> {
		
		return
			if (value == "*") [];
			else if (value.endsWith(".*"))
				value.substr(0, value.length - 2).split(".");
			else value.split(".");
	}
	
	public function copyFrom(s:NodeScope):Void {
		for (nsName in s.namespaces.keys()) {
			namespaces[nsName] = s.namespaces[nsName];
		}
	}
}
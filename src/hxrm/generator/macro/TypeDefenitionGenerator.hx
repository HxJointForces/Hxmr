package hxrm.generator.macro;

import hxrm.utils.TypeUtils;
import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.QName;

using StringTools;
using haxe.macro.Tools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TypeDefenitionGenerator
{
	
	public function new() 
	{
	}
	
	public function write(analyzer : NodeAnalyzer, scope:NodeScope, type:String, file:String):TypeDefinition {
		trace('write:$type');

		TypeUtils.prettyPrintType(scope);
		
		var pack = type.split(".");
		var name = pack.pop();
		
		var superTypeParams = [];
		for (tp in scope.typeParams) {
			superTypeParams.push(getTypePath(scope.context.getType(tp)));
		}
		trace(superTypeParams);
		var superClass:TypePath = getTypePath(scope.type);
		trace(superClass);
		var params = [];
		var fields = [];
		
		return {
			pack: pack,
			name: name,
			pos: Context.makePosition( { min:0, max:0, file:file } ),
			meta: [],
			params: params,
			isExtern: false,
			kind: TDClass(superClass, null, false),
			fields:fields
		}
	}
	
	public function cleanCache():Void {
		
	}

	public function getTypePath(t:Type):TypePath {
		var ct = Context.toComplexType(t);
		trace(ct);
		if (ct == null) {
			trace("can't get CT of " + t); // TODO:
			return null;
		}
		switch (ct) {
			case TPath(p): return p;
			case _: trace(ct);  return null;
		}
	}
	
}
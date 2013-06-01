package hxrm.generator.macro;

import hxrm.analyzer.initializers.BindingInitializator;
import hxrm.analyzer.initializers.IInitializator;
import hxrm.analyzer.QNameUtils;
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
	
	var pos:Position;
	
	// analyzer вроде и не нужен
	public function write(analyzer : NodeAnalyzer, scope:NodeScope, type:String, file:String):TypeDefinition {
		trace('write:$type');

		pos = Context.makePosition( { min:0, max:0, file:file } );
		var qName : QName = QNameUtils.fromHaxeTypeId(type);
		
		var params = [];
		var fields = [];
		
		fields.push(generateCtor(scope));
		
		return {
			pack: qName.packageNameParts,
			name: qName.className,
			pos: pos,
			meta: [],
			params: params,
			isExtern: false,
			kind: TDClass(getTypePath(scope.type), null, false),
			fields:fields
		}
	}
	
	function generateCtor(scope:NodeScope):Field
	{
		var ctorFields = [];
		
		var callSuper = false;
		var parentType = scope.classType;
		while (parentType != null && !callSuper) { // :)
			callSuper = parentType.constructor != null; // добавить проверку на кол-во парамеров !+0
			parentType = parentType.superClass != null ? parentType.superClass.t.get() : null;
		}
		if (callSuper) ctorFields.push(macro super());
		
		// initializers
		for (fieldName in scope.initializers.keys()) {
			var initializator : IInitializator = scope.initializers[fieldName];
			
			if(!Std.is(initializator, BindingInitializator)) {
				continue;
			}
			
			var bind = cast(initializator, BindingInitializator);
			
			var value = null;
			try {
				value = Context.parseInlineString(bind.value, pos);
			} catch (e:Dynamic) {
				throw "can't parse value: " + e;
			}
			var valueType = Context.typeof(value);
			var field = null;
			
			for (f in scope.classFields)
				if (f.name == fieldName) field = f;
			
			if (field == null)
				throw 'class ${scope.type} doesn\'t have field $fieldName';
			
			var res = if (!Context.unify(valueType, field.type)) {
					// extensions must be here
					var fieldCT = scope.context.getClassType(field.type);
					switch([fieldCT.module, fieldCT.name]) {
						case ["String", "String"]:
							macro Std.string($value);
						case ["Int", "Int"]:
							macro Std.parseInt(Std.string($value));
						case ["Float", "Float"]:
							macro Std.parseFloat(Std.string($value));
						case _:
							throw 'can\'t unify value:$valueType to fieldType:${field.type}';
					}
				}
				else
					value;
			
			ctorFields.push(macro $i { fieldName } = $res);
		}
		
		for (child in scope.children) {
			var childExpr = generateChild(child, scope);
			if (childExpr != null)
				ctorFields = ctorFields.concat(childExpr);
		}
		
		var ctorExpr = { expr:EBlock(ctorFields), pos:pos };
		
		return {
			name: "new",
			doc: "autogenerated constructor",
			access: [APublic],
			pos: pos,
			kind: FFun({args:[], ret:null, expr:ctorExpr, params:[]})
		}
	}
	
	function generateChild(child:NodeScope, root:NodeScope):Array<Expr> {
		return null;
		var fieldName = child.context.node.name.localPart;
		var field = null;
		for (f in root.classFields) {
			if (f.name == fieldName) {
				field = f.type;
				break;
			}
		}
		if (field == null) {
			throw 'class ${child.type} doesn\'t have field $fieldName';
		}
		var res = [];
		
		for (c in child.children) {
			var genChild = generateChild(c, child);
			if (genChild != null) res = res.concat(genChild);
		}
		
		
		return res.length > 0 ? res : null;
	}
	
	public function cleanCache():Void {
		
	}

	function getTypePath(t:Type):TypePath {
		var ct = Context.toComplexType(t);
		if (ct == null) throw "can't get CT of " + t;
		
		switch (ct) {
			case TPath(p): return p;
			case _:
				throw "can't get TypePath of " + t + " (" + ct + ")";
		}
	}
	
}
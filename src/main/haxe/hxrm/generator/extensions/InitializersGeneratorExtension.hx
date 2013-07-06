package hxrm.generator.extensions;

import hxrm.analyzer.initializers.IInitializator;
import haxe.CallStack;
import haxe.macro.TypeTools;
import haxe.macro.Printer;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import hxrm.analyzer.QName;
import hxrm.analyzer.QNameUtils;
import hxrm.HxmrContext;
import hxrm.utils.TypeUtils;
import haxe.macro.ComplexTypeTools;
import hxrm.generator.GeneratorScope;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import hxrm.analyzer.NodeScope;
import hxrm.analyzer.initializers.FieldInitializator;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.BaseType;
import hxrm.analyzer.initializers.BindingInitializator;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;

class InitializersGeneratorExtension extends GeneratorExtensionBase {

	public override function generate(context:HxmrContext, scope:GeneratorScope):Bool {

		if(scope.ctor == null) {
			return true;
		}
		
		processScope(context, scope, scope.context.node, scope.ctorExprs, "this");

		return false;
	}

	function processScope(context : HxmrContext, scope : GeneratorScope, nodeScope : NodeScope, exprs : Array<Expr>, forField : String) : Void {

		// initializers
		var initializers = nodeScope.initializers;
		for (fieldName in initializers.keys()) {
			switch(initializers.get(fieldName)) {
				case InitField(initializator):
					parseFieldInitializator(context, scope, initializator);
				case InitBinding(initializator):
			}
			//trace("\n" + (new Printer("   ")).printTypeDefinition(scope.typeDefinition, true));
		}
		for (fieldName in initializers.keys()) {
			var fieldBaseType = getFieldTypeByName(scope, nodeScope, fieldName);
			var res = switch(initializers.get(fieldName)) {
				case InitBinding(initializator):
					parseBindingInitializator(context, scope, nodeScope, fieldBaseType, initializator, exprs);
				case InitField(initializator):
					parseBindingInitializator(context, scope, nodeScope, fieldBaseType, initializator, exprs);
			};
			
			exprs.push(macro $i{forField}.$fieldName = $res);
			//trace("\n" + (new Printer("   ")).printTypeDefinition(scope.typeDefinition, true));
		}
	}

	function parseFieldInitializator(context : HxmrContext, scope : GeneratorScope, initializator : FieldInitializator) : Void {

		if(initializator.fieldName == null) {
			//TODO
			trace("fieldName is null!!");
			return null;
		}
		var fieldComplexType : ComplexType = Context.toComplexType(initializator.fieldType);

		var field : Field = {
			name : initializator.fieldName,
			doc : "autogenerated NodeScope field " + initializator.fieldType,
			access : [APublic],
			pos : scope.context.pos,
			kind : FVar(fieldComplexType)
		};
		scope.typeDefinition.fields.unshift(field);
	}
	
	function getBaseType(type : haxe.macro.Type) : BaseType {
		if(type == null) {
			throw "type is null!";
		}
		return switch(type) {
			case TAbstract( t, params ):
				t.get();
			case TInst(t, parsms):
				t.get();
			case TDynamic(t):
				getBaseType(t);
			case _: throw "assert" + type;
		}
	}

	function parseBindingInitializator(context:HxmrContext, scope:GeneratorScope, nodeScope : NodeScope, fieldType : haxe.macro.Type, initializator : BindingInitializator, exprs : Array<Expr>) : Expr {
		
		var fieldClassType = getBaseType(fieldType);
		return switch(new QName(fieldClassType.module.split(QName.HAXE_ID_GLUE), fieldClassType.name).toHaxeTypeId()) {
			
			case "String.String", "StdTypes.Int", "StdTypes.Float":
				var value = getValue(scope, initializator.value);
				if(initializator.fieldName != null) {
					exprs.push(macro $i {initializator.fieldName} = $value);
					macro $i {initializator.fieldName};
				} else {
					macro $value;
				}
			
			case "Array.Array":
				var values : Array<Expr> = [];
				for(childScope in cast(initializator.value, Array<Dynamic>)) {
					var childInit : IInitializator = untyped childScope;
					
					var res = switch(childInit) {
						case InitBinding(initializator):
							parseBindingInitializator(context, scope, nodeScope, Context.getType("Dynamic"), initializator, exprs);
						
						case InitField(initializator):
							parseFieldInitializator(context, scope, initializator);
							parseBindingInitializator(context, scope, nodeScope, Context.getType("Dynamic"), initializator, exprs);
					};
					values.push(res);
				}
				{
					expr : EArrayDecl(values),
					pos : Context.currentPos()
				};

			case t:
				//trace("_ " + t);
				var exprs : Array<Expr> = [];
				var initScope : NodeScope = cast(initializator.value, NodeScope);

				exprs.push(macro if($i { initializator.fieldName } != null) return $i {initializator.fieldName});
				
				var ctor = {
					expr : ENew({
						name : initScope.typeName.className,
						pack : initScope.typeName.packageNameParts,
						params : []
					},
					[]),
					pos : scope.context.pos
				}
	
				var assignTarget = macro $i {initializator.fieldName};
				exprs.push(macro $assignTarget = ${ctor});

				processScope(context, scope, initScope, exprs, initializator.fieldName);
	
				exprs.push(macro return $i { initializator.fieldName });

				var initFunction : Field = {
					name: generateInitializerName(initializator.fieldName),
					doc: "autogenerated NodeScope init function",
					access: [APrivate],
					pos: scope.context.pos,
					kind: FFun({
						args:[],
						ret:null,
						params:[],
						expr: {
							expr : EBlock(exprs),
							pos : scope.context.pos
						}
					})
				}
				scope.typeDefinition.fields.push(initFunction);
				
				macro $i { initFunction.name }();
		};
	}

	function getValue(scope : GeneratorScope, value : Dynamic) : Expr {
		try {
			return Context.parse(value, scope.context.pos);
		} catch (e:Dynamic) {
			trace(e);
			//throw " can't parse value: " + e;
		}
		return null;
	}

	function getFieldTypeByName(scope : GeneratorScope, nodeScope : NodeScope, fieldName : String) : haxe.macro.Type {

		var field : ClassField = nodeScope.getFieldByName(fieldName);
		if(field != null)
		{
			return field.type;
		}
		
		for(field in scope.typeDefinition.fields) {
			if(field.name == fieldName) {
				return getFieldType(field);
			}
		}
		
		return null;
	}
	
	function getFieldType(field : Field) : haxe.macro.Type {
		return switch(field.kind) {
			case FVar(type, _), FProp(_, _, type, _):
				if (type != null) 
					ComplexTypeTools.toType(type);
				else null;
			case _: throw "assert";
		}
	}

	inline function generateInitializerName(fieldName : String) : String {
		return "init_" + fieldName;
	}

}

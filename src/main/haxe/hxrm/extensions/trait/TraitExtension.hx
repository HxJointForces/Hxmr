package hxrm.extensions.trait;

import haxe.macro.Context;
import haxe.macro.Printer;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import hxrm.analyzer.NodeScope;
import hxrm.analyzer.QNameUtils;
import hxrm.extensions.base.IHxmrExtension;
import hxrm.generator.GeneratorScope;
import hxrm.HxmrContext;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLQNameUtils;
import haxe.macro.Type;
import haxe.macro.Expr;
import hxrm.utils.TypeUtils;

using haxe.macro.Tools;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

enum TraitAnalyzerErrorType {
	TRAIT_WITH_CTOR(type:String);
	TRAIT_IS_INTERFACE(type:String);
	TRAIT_IMPLEMENTS_INTERFACE(type:String);
	TRAIT_EXTENDS_CLASS(type:String);
}

class TraitAnalyzerError extends NodeAnalyzerError {
	public function new(type : TraitAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

class TraitExtension implements IHxmrExtension
{

	public function new() 
	{
		
	}
	
    public function analyze(context : HxmrContext, scope : NodeScope) : Bool {
		
		var node : MXMLNode = scope.context.node;
		
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(context, scope, attributeQName, value, node.attributesPositions);
		}
		
		return false;
	}

	function matchAttribute(context : HxmrContext, scope : NodeScope, attributeQName:MXMLQName, value:String, attributesPositions:Map<MXMLQName, Pos>):Void {

		if(attributeQName.localPart != "trait") {
			return;
		}
		
		//TODO remove hardcoded string
		if(MXMLQNameUtils.resolveNamespaceValue(scope.context.node, attributeQName.namespace) != "http://haxe.org/hxmr/trait") {
			return;
		}

		scope.traits = value.split(",").map(QNameUtils.fromHaxeTypeId).map(scope.context.getType).map(scope.context.getClassType);
		
		for (trait in scope.traits) {
			if (trait.constructor != null)
				context.error(new TraitAnalyzerError(TRAIT_WITH_CTOR(trait.name), PosTools.positionToPos(trait.pos)));
			
			if (trait.isInterface)
				context.error(new TraitAnalyzerError(TRAIT_IS_INTERFACE(trait.name), PosTools.positionToPos(trait.pos)));
				
			if (trait.interfaces.length > 0)
				context.error(new TraitAnalyzerError(TRAIT_IMPLEMENTS_INTERFACE(trait.name), PosTools.positionToPos(trait.pos)));
				
			if (trait.superClass != null)
				context.error(new TraitAnalyzerError(TRAIT_EXTENDS_CLASS(trait.name), PosTools.positionToPos(trait.pos)));
		}
		
	}

    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
		
		for (trait in scope.context.node.traits) {
			
			for (field in trait.fields.get())
				scope.typeDefinition.fields.push(getField(field));
			
			for (field in trait.statics.get()) {
				var f = getField(field);
				f.access.push(AStatic);
				scope.typeDefinition.fields.push(f);
			}
		}
		
		return false;
	}
	
	function getField(field:ClassField):Field {
		
		var typedExpr = field.expr();
		var expr = typedExpr != null ? Context.getTypedExpr(typedExpr) : null;
		var f = {
			name: field.name,
			doc: field.doc,
			pos: field.pos,
			meta: field.meta.get(),
			kind: null,
			access: []
		};
		
		f.kind = switch (field.kind) {
			case FieldKind.FVar(read, write):
				
				if (read == AccInline) {
					f.access.push(AInline);
					FieldType.FVar(null, expr);
				} else if (read == AccNormal && write == AccNormal)
					FieldType.FVar(null, expr);
				else
					FieldType.FProp(getAccess(read, true), getAccess(write, false), null, expr);
					
			case FieldKind.FMethod(k):
				switch (k) {
					case MethInline: f.access.push(AInline);
					case MethDynamic: f.access.push(ADynamic);
					case MethMacro: f.access.push(AMacro);
					case MethNormal:
				}
				FieldType.FFun(switch (expr.expr) {
						case EFunction(name, f): f;
						case _: throw "assert";
					});
		};
		
		if (field.isPublic) f.access.push(APublic);
		
		return f;
	}
	
	function getAccess(a:VarAccess, read:Bool):String {
		return switch (a) {
			case AccNever: "never";
			case AccNo: "null";
			case AccNormal: "default";
			case AccCall: read ? "get" : "set";
			case _: trace("! " + a); "default";
		}
	}
	
}
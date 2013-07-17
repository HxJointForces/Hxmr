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
import traits.Trait;

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

		var traits = value.split(",");
		
		scope.traits = [];
		for (trait in traits) {
			var type = QNameUtils.fromHaxeTypeId(trait);
			scope.traits.push({ name:type.className, pack:type.packageNameParts, params:[] });
		}

	}

    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
		
		for (trait in scope.context.node.traits)
			scope.interfaces.push(trait);
			
		return false;
	}
	
}
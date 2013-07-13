package hxrm.extensions.generic;

import hxrm.generator.GeneratorScope;
import hxrm.extensions.base.IHxmrExtension;
import hxrm.analyzer.QNameUtils;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import hxrm.parser.mxml.MXMLQNameUtils;
import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;

enum GenericTypeAnalyzerErrorType {
	INCORRECT_TYPE_PARAMS_COUNT;
}

class GenericTypeAnalyzerError extends NodeAnalyzerError {
	public function new(type : GenericTypeAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

class GenericTypeExtension implements IHxmrExtension {

    public function new() {
    
    }

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		
		if(scope.type == null) {
			return true;
		}
		
		var node : MXMLNode = scope.context.node;
		
		//var resolvedQName : QName = scope.context.resolveQName(node.name);
		
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(context, scope, attributeQName, value, node.attributesPositions);
		}
		
		return false;
	}

	function matchAttribute(context : HxmrContext, scope : NodeScope, attributeQName:MXMLQName, value:String, attributesPositions:Map<MXMLQName, Pos>):Void {

		if(attributeQName.localPart != "type") {
			return;
		}

		//TODO remove hardcoded string
		if(MXMLQNameUtils.resolveNamespaceValue(scope.context.node, attributeQName.namespace) != "http://haxe.org/hxmr/generic") {
			return;
		}

		var typeParams = value.split(",").map(QNameUtils.fromHaxeTypeId);

		//trace(typeParams);

		switch (scope.type) {
			case TInst(t, params):
				if (params.length != typeParams.length) {
					context.error(new GenericTypeAnalyzerError(INCORRECT_TYPE_PARAMS_COUNT, attributesPositions.get(attributeQName)));
					return;
				}

				var genericTypes = [];
				for (genericType in typeParams) {
					genericTypes.push(scope.context.getType(genericType));
				}
				//trace(genericTypes);
				scope.type = TInst(t, genericTypes);
			case _:
		}
	}

    // return true if it needs one more iteration
    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
        return false;
    }

}

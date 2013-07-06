package hxrm.analyzer.extensions;

import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;
import haxe.macro.Context;
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

class GenericTypeExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		
		if(scope.type == null) {
			return true;
		}
		
		var node : MXMLNode = scope.context.node;
		
		//var resolvedQName : QName = scope.context.resolveQName(node.name);
		
		for (attributeQName in node.attributes.keys()) {
			var value : String = node.attributes.get(attributeQName);
			matchAttribute(context, scope, attributeQName, value);
		}
		
		return false;
	}

	function matchAttribute(context : HxmrContext, scope : NodeScope, attributeQName:MXMLQName, value:String):Void {

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
					context.error(new GenericTypeAnalyzerError(INCORRECT_TYPE_PARAMS_COUNT));
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

}

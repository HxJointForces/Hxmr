package hxrm.analyzer.extensions;

import hxrm.parser.mxml.MXMLQName;
import StringTools;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;

using StringTools;

enum TypeAnalyzerErrorType {
	CANT_INSTANTIATE_INTERFACE;
	CANT_INSTANTIATE_PRIVATE_CLASS;
	ID_CANT_BE_NULL;
}

class TypeAnalyzerError extends NodeAnalyzerError {
	public function new(type : TypeAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TypeExtension extends NodeAnalyzerExtensionBase {

	override public function analyze(context : HxmrContext, scope:NodeScope):Bool {
		var node : MXMLNode = scope.context.node;

		scope.typeName = scope.context.resolveQName(node.name);

		if(scope.type == null) {
			scope.type = scope.context.getType(scope.typeName);
		}
		
		if(scope.classType == null) {
			scope.classType = scope.context.getClassType(scope.type);
		}

		if (scope.classType.isInterface) {
			context.error(new TypeAnalyzerError(CANT_INSTANTIATE_INTERFACE));
			return false;
		}

		if (scope.classType.isPrivate) {
			context.error(new TypeAnalyzerError(CANT_INSTANTIATE_PRIVATE_CLASS));
			return false;
		}
		
		if(scope.classFields == null) {
			scope.classFields = new Map();
			var currentClassType = scope.classType;
			while (currentClassType != null) {
				for (classField in currentClassType.fields.get()) {
					scope.classFields.set(classField.name, classField);
				}
				currentClassType = currentClassType.superClass != null ? currentClassType.superClass.t.get() : null;
			}
		}
		
		
		
		return false;
	}
	
}
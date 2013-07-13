package hxrm.extensions.basicType;

import hxrm.extensions.base.INodeAnalyzerExtension;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.NodeScope;

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

class BasicTypeAnalyzerExtension implements INodeAnalyzerExtension {

    public function new() {
    
    }

    public function analyze(context : HxmrContext, scope:NodeScope):Bool {
        var node : MXMLNode = scope.context.node;

        scope.typeName = scope.context.resolveQName(node.name);

        if(scope.type == null) {
            scope.type = scope.context.getType(scope.typeName);
        }

        if(scope.classType == null) {
            scope.classType = scope.context.getClassType(scope.type);
        }

        if (scope.classType.isInterface) {
            context.error(new TypeAnalyzerError(CANT_INSTANTIATE_INTERFACE, node.position));
            return false;
        }

        if (scope.classType.isPrivate) {
            context.error(new TypeAnalyzerError(CANT_INSTANTIATE_PRIVATE_CLASS, node.position));
            return false;
        }

        if(scope.classFields == null) {
            scope.classFields = new Map();
        }

        var currentClassType = scope.classType;
        while (currentClassType != null) {
            for (classField in currentClassType.fields.get()) {
                scope.classFields.set(classField.name, classField);
            }
            currentClassType = currentClassType.superClass != null ? currentClassType.superClass.t.get() : null;
        }



        return false;
    }

}

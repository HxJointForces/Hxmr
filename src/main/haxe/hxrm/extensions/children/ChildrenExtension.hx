package hxrm.extensions.children;

import hxrm.extensions.fields.FieldsExtension;
import hxrm.extensions.properties.PropertiesExtension;
import hxrm.generator.GeneratorScope;
import hxrm.extensions.base.IHxmrExtension;
import hxrm.extensions.properties.PropertiesAnalyzerExtension;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;
import hxrm.parser.mxml.MXMLQName;
import hxrm.HxmrContext.Pos;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;
import StringTools;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQNameUtils;

enum ChildrenAnalyzerErrorType {
	CDATA_WITH_INNER_TAGS;
	DEFAULT_PROPERTY_IS_NULL;
}

class ChildrenAnalyzerError extends NodeAnalyzerError {
	public function new(type : ChildrenAnalyzerErrorType, ?pos : Pos) {
		super(type, pos);
	}
}

class ChildrenExtension implements IHxmrExtension {

    public function new() {
    
    }

	public function analyze(context : HxmrContext, scope:NodeScope):Bool {

		if(scope.initializers == null || scope.getTopScope().fields == null) {
			return true;
		}

		var node : MXMLNode = scope.context.node;
		
		if(node.children.length > 0 && node.cdata != null && node.cdata.length > 0) {
			context.error(new ChildrenAnalyzerError(CDATA_WITH_INNER_TAGS, node.position));
			return false;
		}

		if(node.children.length == 0) {
			return false;
		}

        var defaultProperty;
        for(field in scope.classFields) {
			if(!field.meta.has("hxmrDefaultProperty")) {
				continue;
			}

			if(defaultProperty != null) {
				//TODO DUPLICATE_DEFAULT_PROPERTY with use pos from base class!!!
				return false;
			}

			defaultProperty = field.name;
		}
		
		var arrayNode : MXMLNode = new MXMLNode();
		arrayNode.name = new MXMLQName(MXMLQName.ASTERISK, "Array");

        var propertiesExtension = context.getExtension(PropertiesExtension);

        for (childNode in node.children) {
			if(propertiesExtension.analyzer.isInnerProperty(scope, childNode)) {
				continue;
			}

			//TODO better typename checking
			var resolveNamespaceValue = MXMLQNameUtils.resolveNamespaceValue(childNode, childNode.name.namespace);
			if(StringTools.startsWith(resolveNamespaceValue, "http://")) {
				continue;
			}

			arrayNode.children.push(childNode);
		}
		
		if(arrayNode.children.length == 0) {
			return false;
		}
		
		if(defaultProperty == null) {
			trace("defaultPropertyIsNull");
			context.error(new ChildrenAnalyzerError(DEFAULT_PROPERTY_IS_NULL, node.position));
			return false;
		}

		var setterArrayNode : MXMLNode = new MXMLNode();
		setterArrayNode.name = new MXMLQName(node.name.namespace, defaultProperty);
		setterArrayNode.children.push(arrayNode);
		
        var value = propertiesExtension.analyzer.matchChild(context, scope.getTopScope(), setterArrayNode);
        if(value != null){
            context.getExtension(FieldsExtension).analyzer.parseValueForField(context, scope, value);
        }
		return false;
	}

    // return true if it needs one more iteration
    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
        return false;
    }
}

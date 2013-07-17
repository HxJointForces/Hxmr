package hxrm.analyzer;

import hxrm.analyzer.initializers.IItor;
import haxe.ds.HashMap;
import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import haxe.macro.Expr;
import haxe.macro.Type;

class NodeScope {

	public var parentScope : NodeScope;

	public var context : AnalyzerContext;

	public var typeName : QName;
	public var type:Type;
	public var classType:ClassType;

	public var classFields:Map<String, ClassField>;

	public var defaultProperty : String;

    public var initializers : Map<String, IItor>;

    public var fields : Array<{name : String, type : Type}>;
	
	private var fieldNamesSeek : HashMap<QName, Int>;
    
    private var fieldNames : Map<MXMLNode, String>;
	
	public var traits:Array<TypePath>;

	public function new() {
		fieldNamesSeek = new HashMap();
        fieldNames = new Map();

        initializers = new Map();
        fields = [];
		traits = [];
	}
	
	public function getNodeId(node : MXMLNode) : String {
		return node.attributes.get(new MXMLQName(MXMLQName.ASTERISK, "id"));
	}
	
	public function getFieldNameForNode(node : MXMLNode) : String {

		var id = getNodeId(node);

		if(id != null) {
			return id;
		}
        
        var generatedId = fieldNames.get(node);
        if(generatedId != null) {
            return generatedId;
        }
		
		var qName = context.resolveQName(node.name);
		
		var currentScope = this;
		var currentFieldNamesSeek = fieldNamesSeek;
		
		while(currentScope.parentScope != null) {
			currentScope = currentScope.parentScope;
			currentFieldNamesSeek = currentScope.fieldNamesSeek;
		}
		
		if(!currentFieldNamesSeek.exists(qName)) {
			currentFieldNamesSeek.set(qName, 0);
		}
		
		var seek : Int = currentFieldNamesSeek.get(qName);

		currentFieldNamesSeek.set(qName, seek + 1);

        generatedId = qName.packageNameParts.join("_") + "__" + qName.className.substr(0, 1).toLowerCase() + qName.className.substr(1) + Std.string(seek);
        
        fieldNames.set(node, generatedId);
        return generatedId;
	}

	inline public function getFieldByName(name : String) : ClassField {
		return classFields != null ? classFields.get(name) : null;
	}
}
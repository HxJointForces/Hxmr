package hxrm.analyzer;

import StringTools;
import haxe.ds.HashMap;
import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.analyzer.initializers.FieldInitializator;
import hxrm.analyzer.initializers.IInitializator;
import haxe.macro.Type;

class NodeScope {

	public var context : AnalyzerContext;

	public var typeName : QName;
	public var type:Type;
	public var classType:ClassType;

	public var classFields:Map<String, ClassField>;

	public var defaultProperty : String;
	
	public var initializers : Map<String, IInitializator>;
	
	public var children : Array<FieldInitializator>;
	
	private var fieldNamesSeek : HashMap<QName, Int>;

	public function new() {
		fieldNamesSeek = new HashMap();
	}
	
	public function getNodeId(node : MXMLNode) : String {
		return node.attributes.get(new MXMLQName(MXMLQName.ASTERISK, "id"));
	}
	
	public function getFieldNameForNode(node : MXMLNode) : String {

		var id = getNodeId(node);

		if(id != null) {
			return id;
		}
		
		var qName = context.resolveQName(node.name);
		
		if(!fieldNamesSeek.exists(qName)) {
			fieldNamesSeek.set(qName, 0);
		}
		
		var seek : Int = fieldNamesSeek.get(qName);
		
		fieldNamesSeek.set(qName, seek + 1);
		
		return qName.packageNameParts.join("_") + "__" + qName.className.substr(0, 1).toLowerCase() + qName.className.substr(1) + Std.string(seek);
	}

	inline public function getFieldByName(name : String) : ClassField {
		return classFields != null ? classFields.get(name) : null;
	}
}
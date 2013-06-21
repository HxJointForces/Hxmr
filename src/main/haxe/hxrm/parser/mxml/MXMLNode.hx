package hxrm.parser.mxml;

import haxe.ds.HashMap;
class MXMLNode
{
	// нужно везде вписать FilePos, как только мы сможем получать эту информацию
	public var name:MXMLQName;
	public var namespaces:Map<String, String>;
	
	public var attributes:HashMap<MXMLQName, String>;
	
	public var children:Array<MXMLNode>;
	
	public var parentNode : MXMLNode;
	
	public var cdata : String;
	
	public function new() 
	{
		attributes = new HashMap();
		
		namespaces = new Map();
		namespaces.set(MXMLQName.ASTERISK, MXMLQName.ASTERISK);
		
		children = [];
		cdata = "";
	}
	
	public function toString() {
		return toStringTabs(0);
	}
	
	function toStringTabs(indentLevel = 0) {
		var i0 = indent(indentLevel);
		var i1 = indent(indentLevel+1);
		var i2 = indent(indentLevel+2);
		var result : String = i0 + 'MXMLNode(name="$name")';
		
		result += "[\n";

		if(namespaces.keys().hasNext()) {
			result += i1 + "Namespaces:\n";
			for(namespaceName in namespaces.keys())
			{
				result +=  i2 + '$namespaceName : ${namespaces.get(namespaceName)}\n';
			}
		}

		if(attributes.keys().hasNext()) {
			result += i1 + "Attributes:\n";
			for(valueQName in attributes.keys())
			{
				result +=  i2 + '$valueQName : ${attributes.get(valueQName)}\n';
			}
		}

		
		if(children.length > 0) {
			result += i1 + "Children:\n";
			for (childNode in children)
			{
				result += childNode.toStringTabs(indentLevel + 2) + "\n";
			}
		}
		
		if(cdata != null && cdata.length > 0) {
			result += i1 + "CDATA:\n";
			result += cdata + "\n";
		}
		
		result += i0 + "]";
		
		return result;
	}

	inline function indent(indentLevel : Int) {
		var glue : String = "   ";
		return StringTools.rpad("", glue, indentLevel * glue.length);
	}
	
}
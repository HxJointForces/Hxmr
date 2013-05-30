package hxrm.parser.mxml;

class MXMLNode
{
	// нужно везде вписать FilePos, как только мы сможем получать эту информацию
	public var name:QName;
	public var typeParams:Array<QName>;
	public var namespaces:Map<String, String>;
	
	public var values:Map<QName, String>;
	
	public var children:Array<MXMLNode>;
	
	public var parentNode : MXMLNode;
	
	public function new() 
	{
		values = new Map();
		namespaces = new Map();
		typeParams = [];
		children = [];
	}
	
	public function toString() {
		return toStringTabs(0);
	}
	
	function toStringTabs(indentLevel = 0) {
		var i0 = indent(indentLevel);
		var i1 = indent(indentLevel+1);
		var i2 = indent(indentLevel+2);
		var result : String = i0 + 'MXMLNode(name="$name")';
		
		if (typeParams.length > 0) result += " <" + typeParams.join(", ") + "> ";
		
		result += "[\n";
		
		result += i1 + "Namespaces:\n";
		for(namespaceName in namespaces.keys())
		{
			result +=  i2 + '$namespaceName : ${namespaces.get(namespaceName)}\n';
		}

		result += i1 + "Values:\n";

		for(valueQName in values.keys())
		{
			result +=  i2 + '$valueQName : ${values.get(valueQName)}\n';
		}
		
		result += i1 + "Children:\n";
		
		for (childNode in children)
		{
			result += childNode.toStringTabs(indentLevel + 2) + "\n";
		}
		result += i0 + "]";
		
		return result;
	}

	inline function indent(indentLevel : Int) {
		var glue : String = "   ";
		return StringTools.rpad("", glue, indentLevel * glue.length);
	}
	
}
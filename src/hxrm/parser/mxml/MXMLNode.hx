package hxrm.parser.mxml;

/**
 * нодVO
 * TODO: как хранить просто свойста и свойства с неймспейсами? 
 * 		 или тут они уже все должны быть приведены в общий вид
 * 
 * @author deep <system.grand@gmail.com>
 */
class MXMLNode
{
	public var name:QName;
	public var namespaces:Map<String, String>;
	
	public var values:Map<QName, String>;
	
	public var children:Array<MXMLNode>;
	
	public var parentNode : MXMLNode;
	
	public function new() 
	{
		values = new Map();
		namespaces = new Map();
		children = [];
	}
	
	public function toString() {
		return toStringTabs(0);
	}
	
	function toStringTabs(indentLevel = 0) {
		var result : String = indent(indentLevel) + 'MXMLNode(name="$name")[\n';
		
		result += indent(indentLevel+1) + 'Namespaces:\n';
		for(namespaceName in namespaces.keys())
		{
			result +=  indent(indentLevel+2) + '$namespaceName : ${namespaces.get(namespaceName)}\n';
		}

		result += indent(indentLevel+1) + 'Values:\n';

		for(valueQName in values.keys())
		{
			result +=  indent(indentLevel+2) + '$valueQName : ${values.get(valueQName)}\n';
		}
		
		result += indent(indentLevel+1) + 'Children:\n';
		
		for (childNode in children)
		{
			result += childNode.toStringTabs(indentLevel + 2) + "\n";
		}
		result += indent(indentLevel) + "]";
		
		return result;
	}

	inline function indent(indentLevel : Int) {
		var glue : String = "   ";
		return StringTools.rpad("", glue, indentLevel * glue.length);
	}
	
}
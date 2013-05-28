package hxrm.parser;

/**
 * нодVO
 * TODO: как хранить просто свойста и свойства с неймспейсами? 
 * 		 или тут они уже все должны быть приведены в общий вид
 * 
 * @author deep <system.grand@gmail.com>
 */
class Node
{
	public var name:String;
	public var values:Map<String, String>;
	
	public var children:Array<Node>;
	
	public function new() 
	{
		values = new Map();
		children = [];
	}
	
	public function toString() {
		return "\n" + toStringTabs();
	}
	
	function toStringTabs(tabs = "") {
		return '$tabs[$name:\n' +
			[for (k in values.keys()) '${tabs}\t$k : ${values.get(k)}'].join("\n") + 
			[for (c in children) c.toStringTabs(tabs + "\t")].join("\n--------------\n") +
			'\n$tabs]';
		
	}
	
}
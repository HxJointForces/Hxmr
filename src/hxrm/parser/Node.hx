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
	public var namespace:Null<String>;  // null если не задан
	public var namespaces:Map<String, String>;
	
	public var values:Map<String, String>;
	
	public var children:Array<Node>;
	
	public function new() 
	{
		values = new Map();
		namespaces = new Map();
		children = [];
	}
	
	public function toString() {
		return "\n" + toStringTabs();
	}
	
	function toStringTabs(tabs = "") {
		return '$tabs[$namespace:$name:\n' +
			'${tabs}Namespaces:\n' +
			[for (k in namespaces.keys()) '${tabs}\t$k : ${namespaces.get(k)}'].join("\n") + 
			'\n${tabs}Values:\n' +
			[for (k in values.keys()) '${tabs}\t$k : ${values.get(k)}'].join("\n") + 
			'\n${tabs}Children:\n' +
			[for (c in children) c.toStringTabs(tabs + "\t")].join("\n--------------\n") +
			'\n$tabs]';
		
	}
	
}
package hxrm.parser;

/**
 * нодVO
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
	
}
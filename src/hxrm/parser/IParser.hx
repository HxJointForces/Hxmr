package hxrm.parser;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface IParser
{

	public function parse(data:String, ?path:String):Null<Node>;
	
	public function cleanCache():Void;
	
}
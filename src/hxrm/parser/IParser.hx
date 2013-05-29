package hxrm.parser;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface IParser
{

	public function parse(data:String):Null<Node>;
	
	public function cleanCache():Void;
	
}
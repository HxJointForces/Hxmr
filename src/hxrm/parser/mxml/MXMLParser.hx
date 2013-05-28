package hxrm.parser.mxml;

import hxrm.parser.IParser;
import hxrm.parser.Tools;
import hxrm.parser.Node;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class MXMLParser implements IParser
{

	public function new() 
	{
		cache = new Map();
	}
	
	var xml:Xml;
	var path:String;
	var node:Node;
	
	var cache:Map<String, Node>;
	
	public function parse(data:String, ?path:String):Null<Node> {
		
		node = null;
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			#if debug
			throw e;
			#else
			throw Messages.UNKNOWN_FILE_FORMAT;
			#end
		}
		
		this.path = path;
		
		doParse(xml.firstChild()); // haxe.xml.Fast ?
		
		return node;
	}
	
	function doParse(x:Xml) {
		// do magic here
	}
	
	public function cleanCache():Void {
		cache = new Map();
	}
	
}
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
	}
	
	var xml:Xml;
	var path:String;
	var node:Node;
	
	var pos:FilePos;
	
	public function parse(data:String, ?path:String):Null<Node> {
		
		node = null;
		pos = { file:path };
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			throw new ParserError(UNKNOWN_FILE_FORMAT, pos);
		}
		
		this.path = path;
		
		node = doParse(xml.firstElement()); // haxe.xml.Fast ?
		
		return node;
	}
	
	function doParse(x:Xml) {
		// do magic here
		if (x == null) throw new ParserError(EMPTY_FILE, pos);
		
		var n = new Node();
		
		n.name = x.nodeName;
		for (a in x.attributes()) {
			n.values.set(a, x.get(a));
		}
		
		for (c in x.elements()) {
			n.children.push(doParse(c));
		}
		return n;
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
	
}
package hxrm.parser.mxml;

import hxrm.parser.IParser;
import hxrm.parser.Tools;
import hxrm.parser.Node;

using StringTools;
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
		
		node = doParse(xml.firstElement(), true); // haxe.xml.Fast ?
		
		return node;
	}
	
	// root - первый нод в xml
	function doParse(x:Xml, root = false) {
		// do magic here
		if (x == null) throw new ParserError(EMPTY_FILE, pos);
		
		var n = new Node();
		
		parseAttributes(x, n);
		
		var name = parseId(x.nodeName);
		n.namespace = name.prefix == null ? "*" : name.prefix;
		n.name = name.name;
		
		for (c in x.elements()) {
			n.children.push(doParse(c));
		}
		
		return n;
	}
	
	function parseAttributes(x:Xml, n:Node) {
		
		for (a in x.attributes()) {
			
			var aName = parseId(a);
			var value = x.get(a);
			
			// TODO: вынести парсеры особых атрибутов отдельно, может сделать плагины с правилами
			if (aName.prefix == null && aName.name == "xmlns") {
				n.namespaces["*"] = value; 
			}
			else if (aName.prefix == "xmlns") {
				n.namespaces[aName.name] = value;
			}
			else
				n.values.set(a, value);
		}
	}
	
	function parseId(s:String): { prefix:String, name:String } {
		var a = s.split(":");
		if (a.length == 1) return { prefix:null, name:s };
		else return { prefix:a[0], name:a[1] };
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
	
}
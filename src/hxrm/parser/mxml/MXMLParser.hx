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
		
		n.name = QName.fromString(x.nodeName);
		
		for (c in x.elements()) {
			n.children.push(doParse(c));
		}
		
		return n;
	}
	
	function parseAttributes(x:Xml, n:Node) {
		
		for (attributeName in x.attributes()) {
			
			var attributeQName = QName.fromString(attributeName);
			var value = x.get(attributeName);
			
			// TODO: вынести парсеры особых атрибутов отдельно, может сделать плагины с правилами
			if (attributeQName.namespace == "*" && attributeQName.localPart == "xmlns") {
				n.namespaces["*"] = value;
			}
			else if (attributeQName.namespace == "xmlns") {
				n.namespaces[attributeQName.localPart] = value;
			}
			else
				n.values.set(attributeQName, value);
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
	
}
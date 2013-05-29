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
	
	// TODO Should it realy be a field?
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
		
		node = parseRootNode(xml); // haxe.xml.Fast ?
		
		return node;
	}
	
	function parseRootNode(node : Xml) {
		var firstElement = node.firstElement();
		
		if (firstElement == null) {
			throw new ParserError(EMPTY_FILE, pos);
		}
		
		return parseNode(firstElement);
	}

	// root - первый нод в xml
	function parseNode(xmlNode : Xml) {
	
		// do magic here
		var n = new Node(QName.fromString(xmlNode.nodeName));

		parseAttributes(xmlNode, n);

		//TODO inner property setters
		for (c in xmlNode.elements()) {
			n.children.push(parseNode(c));
		}

		return n;
	}
	
	function parseAttributes(x:Xml, n:Node) {
	
		
		for (attributeName in x.attributes()) {
			
			var attributeQName = QName.fromString(attributeName);
			var value = x.get(attributeName);
			
			// TODO: вынести парсеры особых атрибутов отдельно, может сделать плагины с правилами
			switch [attributeQName.namespace, attributeQName.localPart] {
				case [ "*", "xmlns" ]:
					n.namespaces["*"] = value;
				case [ "xmlns", _ ]:
					n.namespaces[attributeQName.localPart] = value;
				case _:
					n.values.set(attributeQName, value);
			}
				
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
	
}
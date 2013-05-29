package hxrm.parser.mxml;

import hxrm.parser.Tools;
import hxrm.parser.Node;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class MXMLParser
{
	public function new() 
	{
	}
	
	// TODO Should it realy be a field?
	var xml:Xml;
	
	public function parse(data:String):Null<Node> {
		
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			throw new ParserError(UNKNOWN_DATA_FORMAT, { pos : { to : 0 , from : 0 } });
		}
		
		return parseRootNode(xml); // haxe.xml.Fast ?
	}
	
	function parseRootNode(node : Xml) {
		var firstElement = node.firstElement();
		
		if (firstElement == null) {
			throw new ParserError(EMPTY_DATA, { pos : { to : 0 , from : 0 } });
		}
		
		return parseNode(firstElement);
	}

	// root - первый нод в xml
	function parseNode(xmlNode : Xml) {
	
		// do magic here
		var n = new Node(QName.fromString(xmlNode.nodeName));

		parseAttributes(xmlNode, n);
		parseChildren(xmlNode, n);

		return n;
	}
	
	function parseChildren(xmlNode:Xml, n:Node) {
		//TODO inner property setters
		for (c in xmlNode.elements()) {
			n.children.push(parseNode(c));
		}
	}
	
	function parseAttributes(xmlNode:Xml, n:Node) {
		for (attributeName in xmlNode.attributes()) {
			
			var attributeQName = QName.fromString(attributeName);
			var value = xmlNode.get(attributeName);
			
			//TODO support for external matchers
			var matchers : Array<IAttributeMatcher> = [new NamespaceAttributeMatcher()];
			var matchersIterator : Iterator<IAttributeMatcher> = matchers.iterator();

			if(!matchersIterator.hasNext() || !matchersIterator.next().matchAttribute(attributeQName, value, n, matchersIterator)) {
				n.values.set(attributeQName, value);
			}
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
	
}

interface IAttributeMatcher {
	function matchAttribute(attributeQName : QName, value : String, n : Node, iterator : Iterator<IAttributeMatcher>) : Bool;
}

class NamespaceAttributeMatcher implements IAttributeMatcher {
	public function new() {
	}

	public function matchAttribute(attributeQName : QName, value : String, n : Node, iterator : Iterator<IAttributeMatcher>) : Bool {
		switch [attributeQName.namespace, attributeQName.localPart] {
			case [ "*", "xmlns" ]:
				n.namespaces["*"] = value;
				return true;
			
			case [ "xmlns", _ ]:
				n.namespaces[attributeQName.localPart] = value;
				return true;
			
			case _:
				if(!iterator.hasNext()){
					return false;
				}
				return iterator.next().matchAttribute(attributeQName, value, n, iterator);
		}
	}
}
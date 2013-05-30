package hxrm.parser.mxml;

import hxrm.parser.mxml.attributes.NamespaceAttributeMatcher;
import hxrm.parser.mxml.attributes.IAttributeMatcher;
import hxrm.parser.QName;
import hxrm.parser.Tools;

using StringTools;

class MXMLParser
{
	public function new() 
	{
		matchers = [new NamespaceAttributeMatcher()];
	}
	
	public function parse(data:String):Null<MXMLNode> {
		
		var xml = null;
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			throw new ParserError(UNKNOWN_DATA_FORMAT, { to : 0 , from : 0 });
		}
		
		return parseRootNode(xml);
	}
	
	function parseRootNode(node : Xml):Null<MXMLNode>  {
		var firstElement = node.firstElement();
		
		if (firstElement == null) {
			throw new ParserError(EMPTY_DATA, { to : 0 , from : 0 });
		}
		
		return parseNode(firstElement);
	}

	function parseNode(xmlNode : Xml):Null<MXMLNode>  {
	
		var n = new MXMLNode();
		n.name = QName.fromString(xmlNode.nodeName);

		parseAttributes(xmlNode, n);
		parseChildren(xmlNode, n);

		return n;
	}
	
	function parseChildren(xmlNode:Xml, n:MXMLNode) {
		//TODO inner property setters 
		// я же говорил, пока не получим подробный тип нода, ничего не сделать тут более
		for (c in xmlNode.elements()) {
			var child = parseNode(c);
			child.parentNode = n;
			n.children.push(child);
		}
	}
	
	//TODO support for external matchers - KISS
	public var matchers : Array<IAttributeMatcher>;
	
	function parseAttributes(xmlNode:Xml, n:MXMLNode) {
		for (attributeName in xmlNode.attributes()) {
			
			var attributeQName = QName.fromString(attributeName);
			var value = xmlNode.get(attributeName);
			
			var matchersIterator : Iterator<IAttributeMatcher> = matchers.iterator();
			
			/*
				var matched = false;
				while (matchersIterator.hasNext() && !matched) {
				  matched = am.matchAttribute(....);
				}
				if (!matched) n.values.set(attributeQName, value);
				
				VS
				
			 */
			if(!matchersIterator.hasNext() || !matchersIterator.next().matchAttribute(attributeQName, value, n, matchersIterator)) {
				n.values.set(attributeQName, value);
			}
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
}
package hxrm.parser.mxml;

import StringTools;
import hxrm.parser.Tools;

using StringTools;

class MXMLParser
{
	public function new() {
	}
	
	public function parse(data:String):Null<MXMLNode> {
		
		var xml = null;
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			throw new ParserError(UNKNOWN_DATA_FORMAT, { to : 0 , from : 0 });
		}
		
		return parseNode(xml);
	}
	
	function parseNode(xmlNode : Xml):Null<MXMLNode>  {
	
		if(xmlNode.nodeType == Xml.Document) {
			var firstElement = xmlNode.firstElement();

			if (firstElement == null) {
				throw new ParserError(EMPTY_DATA, { to : 0 , from : 0 });
			}

			return parseNode(firstElement);
		}
		
		var n = new MXMLNode();
		n.name = MXMLQNameUtils.fromQualifiedString(xmlNode.nodeName);

		parseAttributes(xmlNode, n);
		
		for(innerNode in xmlNode.iterator()) {
			if(innerNode.nodeType == Xml.PCData || innerNode.nodeType == Xml.CData) {
				var value = StringTools.trim(innerNode.nodeValue);
				trace(value);
				if(value != null && value.length > 0) {
					n.cdata += value;
				}
			} else {
				parseChild(n, xmlNode, innerNode);
			}
		}

		return n;
	}
	
	function parseChild(n:MXMLNode, xmlNode:Xml, c : Xml) {
		var child : MXMLNode = parseNode(c);
		child.parentNode = n;
		
		for(key in n.namespaces.keys()) {
			if(!child.namespaces.exists(key)) {
				child.namespaces.set(key, n.namespaces.get(key));
			}
		}
		
		n.children.push(child);
	}
	
	function parseAttributes(xmlNode:Xml, n:MXMLNode) {
		for (attributeName in xmlNode.attributes()) {
			
			var attributeQName = MXMLQNameUtils.fromQualifiedString(attributeName);
			var value = xmlNode.get(attributeName);
			
			switch [attributeQName.namespace, attributeQName.localPart] {
				case [ "*", "xmlns" ]:
					n.namespaces[attributeQName.namespace] = value;
				case [ "xmlns", _ ]:
					n.namespaces[attributeQName.localPart] = value;
				case _:
					n.attributes.set(attributeQName, value);
			}
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
}
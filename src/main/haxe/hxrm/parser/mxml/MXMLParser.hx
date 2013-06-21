package hxrm.parser.mxml;

import StringTools;
import hxrm.HxmrContext;

using StringTools;

// константы типов ошибок
enum ParserErrorType {
	UNKNOWN_DATA_FORMAT;
	EMPTY_DATA;
}

class ParserError extends ContextError {
	public function new(type : ParserErrorType) {
		super(type, {from : 0, to : -1});
	}
}

class MXMLParser
{
	public function new() {
	}
	
	public function parse(context : HxmrContext, data:String):Null<MXMLNode> {
		
		var xml = null;
		try {
			xml = Xml.parse(data);
		} catch (e:Dynamic) {
			context.error(new ParserError(UNKNOWN_DATA_FORMAT));
			return null;
		}
		
		return parseNode(context, xml);
	}
	
	function parseNode(context : HxmrContext, xmlNode : Xml):Null<MXMLNode>  {
	
		if(xmlNode.nodeType == Xml.Document) {
			var firstElement = xmlNode.firstElement();

			if (firstElement == null) {
				context.error(new ParserError(EMPTY_DATA));
				return null;
			}

			return parseNode(context, firstElement);
		}
		
		var n = new MXMLNode();
		n.name = MXMLQNameUtils.fromQualifiedString(xmlNode.nodeName);

		parseAttributes(xmlNode, n);
		
		for(innerNode in xmlNode.iterator()) {
			switch(innerNode.nodeType) {
				case Xml.PCData, Xml.CData:
					parseCDATA(n, xmlNode, innerNode);
				case Xml.Element:
					parseChild(context, n, xmlNode, innerNode);
				case Xml.Comment:
				default: throw ("unknown node type: " + innerNode.nodeType);
			}
		}

		return n;
	}
	
	function parseCDATA(n : MXMLNode, xmlNode : Xml, cDataNode : Xml) {
		var value = StringTools.trim(cDataNode.nodeValue);
		if(value != null && value.length > 0) {
			n.cdata += value;
		}
	}
	
	function parseChild(context : HxmrContext, n:MXMLNode, xmlNode:Xml, c : Xml) {
		var child : MXMLNode = parseNode(context, c);
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
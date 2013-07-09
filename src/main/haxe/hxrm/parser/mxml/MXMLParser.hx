package hxrm.parser.mxml;

import StringTools;
import hxrm.HxmrContext;
import com.tenderowls.xml176.Xml176Parser;

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
	var posInfos : Xml176Document;

	public function new() {
	}
	
	public function parse(context : HxmrContext, data:String):Null<MXMLNode> {
		
		posInfos = null;

		try {
			posInfos = Xml176Parser.parse(data);
		} catch (e:Dynamic) {
			context.error(new ParserError(UNKNOWN_DATA_FORMAT));
			return null;
		}
		
		return parseNode(context, posInfos.document);
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
		
		processNode(context, xmlNode, n);

		return n;
	}
	
	function processNode(context : HxmrContext, xmlNode : Xml, n : MXMLNode) : Void {
		n.name = MXMLQNameUtils.fromQualifiedString(xmlNode.nodeName);
		n.position = posInfos.getNodePosition(xmlNode);

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
	}
	
	function parseCDATA(n : MXMLNode, xmlNode : Xml, cDataNode : Xml) {
		var value = StringTools.trim(cDataNode.nodeValue);
		if(value != null && value.length > 0) {
			n.cdata += value;
		}
	}
	
	function parseChild(context : HxmrContext, n:MXMLNode, xmlNode:Xml, c : Xml) {
		var child : MXMLNode = new MXMLNode();
		child.parentNode = n;
		
		for(key in n.namespaces.keys()) {
			if(!child.namespaces.exists(key)) {
				child.namespaces.set(key, n.namespaces.get(key));
			}
		}
		processNode(context, c, child);
		
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
					n.attributesPositions.set(attributeQName, posInfos.getAttrPosition(xmlNode, attributeName));
			}
		}
	}
	
	public function cleanCache():Void {
		// чистим кеши всякой всячины
	}
}
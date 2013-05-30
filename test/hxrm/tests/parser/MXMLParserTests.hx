package hxrm.tests.parser;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLParser;
import haxe.unit.TestCase;
class MXMLParserTests extends TestCase {
	public function new() {
		super();
	}

	public function testSimpleObject() {
		var mxmlParser : MXMLParser = new MXMLParser();
		
		var mxmlNode : MXMLNode = mxmlParser.parse('<String xmlns="*"/>');
		
		assertEquals("*", mxmlNode.name.namespace);
		assertEquals("String", mxmlNode.name.localPart);
		assertEquals(0, mxmlNode.children.length);
		assertEquals(null, mxmlNode.parentNode);
		assertEquals(0, mxmlNode.typeParams.length);
		assertFalse(mxmlNode.values.iterator().hasNext());
	}
}

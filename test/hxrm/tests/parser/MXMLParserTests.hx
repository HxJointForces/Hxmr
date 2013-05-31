package hxrm.tests.parser;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLParser;
import haxe.unit.TestCase;
class MXMLParserTests extends TestCase {
	public function new() {
		super();
	}

	public function testSimpleObject() {
		checkSimpleObjectWithNamespacePrefix('<String xmlns="my.package.*"/>', "my.package.*", "String", "*");
		checkSimpleObjectWithNamespacePrefix('<ns:String xmlns:ns="*"/>', "*", "String", "ns");
	}

	function checkSimpleObjectWithNamespacePrefix(value : String, expectedPackage : String, expectedName : String, expectedNamespace : String) {
		var mxmlParser : MXMLParser = new MXMLParser();
		
		var mxmlNode : MXMLNode = mxmlParser.parse(value);

		assertEquals(expectedNamespace, mxmlNode.name.namespace);
		assertEquals(expectedName, mxmlNode.name.localPart);
		assertEquals(0, mxmlNode.children.length);
		assertEquals(null, mxmlNode.parentNode);
		assertEquals(0, mxmlNode.typeParams.length);
		assertFalse(mxmlNode.attributes.iterator().hasNext());

		assertTrue(mxmlNode.namespaces.exists(expectedNamespace));
		assertEquals(expectedPackage, mxmlNode.namespaces.get(expectedNamespace));
	}
}

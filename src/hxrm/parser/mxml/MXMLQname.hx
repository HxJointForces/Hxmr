package hxrm.parser.mxml;
class MXMLQName {

	public static inline var QUALIFIED_ID_GLUE : String = ":";
	public static inline var ASTERISK : String = "*";

	public var namespace : String;
	public var localPart : String;

	public function new(namespace : String, localPart : String) {
		this.namespace = namespace == null ? ASTERISK : namespace;
		this.localPart = localPart;
	}

	public function toString() : String {
		return '$namespace$QUALIFIED_ID_GLUE$localPart';
	}

	public function hashCode() : Int {
		var qNameAsString : String = toString();

		var hash = 5381;
		for( i in 0...qNameAsString.length) {
			hash = ((hash<<5)+hash)+StringTools.fastCodeAt(haxeTypeId, i);
		}
		return hash;
	}
}

package hxrm.analyzer;
class QName {

	public static inline var HAXE_ID_GLUE : String = ".";
	public static inline var QUALIFIED_ID_GLUE : String = ":";
	public static inline var ASTERISK : String = "*";

	public var packageName : String;
	public var className : String;
	
	public function new(namespace : String, localPart : String) {
		this.packageName = namespace == null ? ASTERISK : namespace;
		this.className = localPart;
	}

	public function toString() : String {
		return '$packageName$QUALIFIED_ID_GLUE$className';
	}

	public function toHaxeTypeId() : String {
		return if(packageName == ASTERISK) className;
				else '$packageName.$className';
	}

	public function hashCode() : Int {
		var haxeTypeId : String = toHaxeTypeId();
		
		var hash = 5381;
		for( i in 0...haxeTypeId.length) {
			hash = ((hash<<5)+hash)+haxeTypeId.charCodeAt(i);
		}
		return hash;
	}
}

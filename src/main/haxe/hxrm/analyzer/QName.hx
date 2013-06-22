package hxrm.analyzer;

class QName {

	public static inline var HAXE_ID_GLUE : String = ".";
	public static inline var QUALIFIED_ID_GLUE : String = ":";

	public var packageNameParts : Array<String>;
	public var className : String;
	
	public function new(packageNameParts : Array<String>, className : String) {
		this.packageNameParts = packageNameParts != null ? packageNameParts : [];
		this.className = className;
	}

	public function toString() : String {
		return '$packageNameParts$QUALIFIED_ID_GLUE$className';
	}

	public function toHaxeTypeId() : String {
		return if(QNameUtils.packageNameIsEmpty(packageNameParts)) {
			className;
		} else {
			QNameUtils.joinPackageNameParts(packageNameParts) + '$HAXE_ID_GLUE$className';
		}
	}

	public function hashCode() : Int {
		var haxeTypeId : String = toHaxeTypeId();
		
		var hash = 5381;
		for( i in 0...haxeTypeId.length) {
			hash = ((hash<<5)+hash)+StringTools.fastCodeAt(haxeTypeId, i);
		}
		return hash;
	}
}

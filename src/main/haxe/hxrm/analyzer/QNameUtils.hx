package hxrm.analyzer;
import StringTools;
import StringTools;
import hxrm.analyzer.QName;
import hxrm.analyzer.QName;
class QNameUtils {

	public static function fromHaxeTypeId(typeId : String) : QName {
		var parts : Array<String> = splitPackage(StringTools.trim(typeId));
		var localName : String = parts.pop();
		return new QName(parts, localName);
	}

	public static function joinPackageNameParts(parts : Array<String>) : String {
		return  parts.join(QName.HAXE_ID_GLUE);
	}
	
	public static function packageNameIsEmpty(parts : Array<String>) : Bool {
		return parts == null || parts.length == 0;
	}

	public static function splitPackage(packageName : String) : Array<String> {
		return StringTools.trim(packageName).split(QName.HAXE_ID_GLUE);
	}

}

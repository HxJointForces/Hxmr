package hxrm.utils;
import hxrm.parser.QName;
import hxrm.parser.QName;
class QNameUtils {

	public static function fromHaxeTypeId(typeId : String) : QName {
		var parts : Array<String> = splitNamespace(typeId);
		var localName : String = parts.pop();
		return new QName(joinNamespaceParts(parts), localName);
	}

	public static function joinNamespaceParts(parts : Array<String>) : String {
		return if(parts.length == 0) QName.ASTERISK;
			else parts.join(QName.HAXE_ID_GLUE);
	}

	public static function splitNamespace(namespace : String) : Array<String> {
		return namespace.split(QName.HAXE_ID_GLUE);
	}

}

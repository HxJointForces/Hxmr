package hxrm.parser.mxml;
class MXMLQNameUtils {
	public static function fromQualifiedString(s: String) : MXMLQName {
		var parts = s.split(MXMLQName.QUALIFIED_ID_GLUE);
		return if (parts.length == 1) {
			new MXMLQName(MXMLQName.ASTERISK, parts[0]);
		} else {
			new MXMLQName(parts[0], parts[1]);
		}
	}
}

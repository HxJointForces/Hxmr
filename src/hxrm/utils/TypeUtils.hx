package hxrm.utils;

class TypeUtils {
	static var r = ~/(.*?=>.*?), /g; // g : replace all instances

	public static function prettyPrintType(type : Dynamic) : Void {
		var scopeAsString : String = Std.string(type);
		scopeAsString = r.replace(scopeAsString, "$1,\n\t");
		trace("ClassType " + scopeAsString.split("{").join("{\n\t").split("}").join("\n}\n"));
	}
}

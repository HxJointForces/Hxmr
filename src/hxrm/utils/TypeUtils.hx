package hxrm.utils;

class TypeUtils {

	public static function prettyPrintType(type : Dynamic) : Void {
		var result : String = "";
		var i : Int = 0;
		var splitted = Std.string(type);
		
		for(index  in 0...splitted.length) {
			var s = splitted.charAt(index);
			result += switch(s) {
				case "{":
					i++;
					"{\n" + indent(i);
				
				case "}":
					i--;
					"\n" + indent(i) + "}";
				
				case ",":
					var nextIndex = index;
					var found = false;
					while(++nextIndex < splitted.length) {
						var nextS = splitted.charAt(nextIndex);

						if(nextS == ",") {
							break;
						} else if(nextS == "=" && (nextIndex + 1) < splitted.length &&  splitted.charAt(nextIndex + 1) == ">") {
							found = true;
							break;
						}
					}
					if(found) {
						",\n" + indent(i);
					} else {
						",";
					}
				
				case "\n":
					"\n" + indent(i);
				case _:
					s;
			}
		}
		
		trace(result);
	}

	static inline function indent(indentLevel : Int) : String {
		var glue : String = "   ";
		return StringTools.rpad("", glue, indentLevel * glue.length);
	}
}

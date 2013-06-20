package hxrm.parser;

/**
 * Общие вещи для всех парсеров. 
 * @author deep <system.grand@gmail.com>
 */

import hxrm.HxmrContext.FilePos;
class Tools {
	
 }

class FilePosUtils {

	public static function toString(p:FilePos, ?file:String) {
		var res = file != null ? file : "";
		if (p.from != null) res += ": " + p.from + "-" + p.to;

		return res;
	}

	static public function toMacroPosition(p:FilePos, file:String) {
		var min = if (p.from != null) p.from; else 0;
		var max = if (p.to != null) p.to; else min;

		return { file:file, min:min, max:max };
	}
}
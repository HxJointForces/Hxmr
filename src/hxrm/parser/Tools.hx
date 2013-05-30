package hxrm.parser;

/**
 * Общие вещи для всех парсеров. 
 * @author deep <system.grand@gmail.com>
 */

 class Tools {
	
 }
 
// нужно придумать как из xml брать номер символа в котором ошибка и по который. 
// Позволит генерировать удобные ерроры открывающиеся прямо в нужном месте
typedef FilePos = { ?from:Int, ?to:Int }

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

// константы типов ошибок
enum ParserErrorType {
	UNKNOWN_DATA_FORMAT;
	EMPTY_DATA;
}

// тип ошибок. класс чтобы ловить кетчем
class ParserError {

	public var type:ParserErrorType;
	public var filePos:FilePos;
		
	public function new(type:ParserErrorType, pos:FilePos) {
		this.type = type;
		filePos = pos;
	}
	
	public function toString() {
		return FilePosUtils.toString(filePos) + " - " +
			switch (type) {
				case UNKNOWN_DATA_FORMAT: "unknown data format or incorrect content";
				case EMPTY_DATA: "data is empty";
			}
	}
}
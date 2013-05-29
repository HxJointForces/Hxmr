package hxrm.parser;

/**
 * Общие вещи для всех парсеров. 
 * @author deep <system.grand@gmail.com>
 */

 class Tools {
	
 }
 
// нужно придумать как из xml брать номер символа в котором ошибка и по который. 
// Позволит генерировать удобные ерроры открывающиеся прямо в нужном месте
typedef FilePos = {
	@:optional var file:String;
	var pos:{from:Int, to:Int};
}

class FilePosUtils {
	
	public static function toString(p:FilePos) {
		var res = p.file;
		if (p.pos != null)
			res += ": " + p.pos.from + "-" + p.pos.to;
			
		return res;
	}
	
	static public function toMacroPosition(p:FilePos) {
		var min = 0;
		var max = 0;
		if (p.pos != null) {
			min = p.pos.from;
			max = p.pos.to;
		}
		return { file:p.file, min:min, max:max };
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
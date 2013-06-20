package hxrm;

// нужно придумать как из xml брать номер символа в котором ошибка и по который. 
// Позволит генерировать удобные ерроры открывающиеся прямо в нужном месте
typedef FilePos = { from:Int, ?to:Int }

// константы типов ошибок
enum ParserErrorType {
	UNKNOWN_DATA_FORMAT;
	EMPTY_DATA;
}

typedef ContextError = {
	type : ParserErrorType,
	?substitutions : Map<String, String>,
	?pos : FilePos
}

class HxmrContext {
	
	public var errors : Array<ContextError>;
	
	public function new() {
		errors = [];
	}

	public function error(err : ContextError) : Void {
		errors.push(err);
	}
}
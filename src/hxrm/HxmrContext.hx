package hxrm;

// нужно придумать как из xml брать номер символа в котором ошибка и по который. 
// Позволит генерировать удобные ерроры открывающиеся прямо в нужном месте
typedef FilePos = { from:Int, ?to:Int }

class ContextError {
	public var filePos:FilePos;

	public function new(pos:FilePos) {
		filePos = pos;
	}
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
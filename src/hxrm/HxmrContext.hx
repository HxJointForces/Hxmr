package hxrm;

// нужно придумать как из xml брать номер символа в котором ошибка и по который. 
// Позволит генерировать удобные ерроры открывающиеся прямо в нужном месте
import EnumValue;
typedef Pos = { from:Int, ?to:Int }

class ContextError {
	private var type:EnumValue;
	private var pos:Pos;

	public function new(type : EnumValue, pos:Pos) {
		this.type = type;
		this.pos = pos;
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
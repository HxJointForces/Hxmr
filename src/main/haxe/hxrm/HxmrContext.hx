package hxrm;

import haxe.CallStack;
import EnumValue;
import haxe.macro.Context;

typedef Pos = { from:Int, ?to:Int }

class ContextError {
	private var type:EnumValue;
	private var pos:Pos;

	public function new(type : EnumValue, pos:Pos) {
		this.type = type;
		this.pos = pos;
	}
	
	public function nativeThrow(file:String) {
		Context.error(
			toString(), 
			Context.makePosition( {
				file:file,
				min:pos.from,
				max:pos.to != null ? pos.to : pos.from 
			} )
		);
	}
	
	public function toString() {
		return Std.string(type);
	}
}

class HxmrContext {
	
	public var errors : Array<ContextError>;
	
	public function new() {
		errors = [];
	}

	public function error(err : ContextError) : Void {
		trace("\n" + CallStack.callStack().join("\n") + "\n" + err);
		errors.push(err);
	}
}
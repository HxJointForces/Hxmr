package hxrm;

import haxe.CallStack;
import EnumValue;
import haxe.macro.Context;
import haxe.macro.Expr.Position;

typedef Pos = { from:Int, ?to:Int }

class PosTools {
	inline static public function toPositionData(p:Pos, file:String): { file:String, min:Int, max:Int } {
		return { file:file, min:p.from, max:p.to != null ? p.to : p.from };
	}
	
	inline static public function toPosition(p:Pos, file:String):Position {
		return Context.makePosition(toPositionData(p, file));
	}
	
	inline static public function positionToPos(pos:Position):Pos {
		var t = Context.getPosInfos(pos);
		return { from:t.min, to:t.max };
	}
}

class ContextError {

	inline static var newLineChar = "\n".code;

	private var type:EnumValue;
	private var pos:Pos;

	public function new(type : EnumValue, pos:Pos) {
		this.type = type;
		this.pos = pos;
	}
	
	public function nativeThrow(file:String) {

		// Find the line
		// Wait then issue https://github.com/HaxeFoundation/haxe/issues/1979 will be fixed
		var i = pos.from;
	    var input = new haxe.io.BytesInput(sys.io.File.getBytes(file));
		var frm = 0;
		var lineNum = 1;

		while (i-- > 0) {
			if (input.readByte() == newLineChar) {
				lineNum++;
				frm = 0;
				continue;
			}
			frm++;
		}

		var too = frm + (pos.to - pos.from);

		Sys.stderr().writeString(file
			+ ":" + lineNum
		    + ": characters "+frm+"-"+too
			+ " : " + toString()
			+ "\n"
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
		trace("\n" + CallStack.toString(CallStack.callStack()) + "\n" + err);
		errors.push(err);
	}
}
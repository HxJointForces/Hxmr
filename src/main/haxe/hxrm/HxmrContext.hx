package hxrm;

import hxrm.extensions.base.IHxmrExtension;
import hxrm.generator.TypeDefinitionGenerator;
import hxrm.analyzer.NodeAnalyzer;
import hxrm.utils.TypeUtils;
import hxrm.extensions.base.IGeneratorExtension;
import hxrm.extensions.base.INodeAnalyzerExtension;
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

    public var analyzerExtensions : Map<String, INodeAnalyzerExtension>;
    
    public var generatorExtensions : Map<String, IGeneratorExtension>;
    
    public var extensions : Map<String, IHxmrExtension>;
    
    public var analyzer : NodeAnalyzer;
    public var generator : TypeDefinitionGenerator;
	
	public function new(analyzer : NodeAnalyzer, generator : TypeDefinitionGenerator) {
        this.analyzer = analyzer;
        this.generator = generator;
		errors = [];
        analyzerExtensions = new Map();
        generatorExtensions = new Map();
        extensions = new Map();
	}

    public function addAnalyzerExtension(ext : INodeAnalyzerExtension) : Void {
        analyzerExtensions.set(Type.getClassName(Type.getClass(ext)), ext);
    }

    public function addGeneratorExtension(ext : IGeneratorExtension) : Void {
        generatorExtensions.set(Type.getClassName(Type.getClass(ext)), ext);
    }

    public function addExtension(ext : IHxmrExtension) : Void {
        extensions.set(Type.getClassName(Type.getClass(ext)), ext);
    }
    
    public function getExtension <T>(extType:Class<T>) : T {
        var extClassName = Type.getClassName(extType);
        var extension = extensions.get(extClassName);

        if(extension != null) {
            return cast extension;
        }
        
        var analyzerExtension = analyzerExtensions.get(extClassName);

        if(analyzerExtension != null) {
            return cast analyzerExtension;
        }

        return cast generatorExtensions.get(extClassName);
    }

	public function error(err : ContextError) : Void {
		trace("\n" + CallStack.toString(CallStack.callStack()) + "\n" + err);
		errors.push(err);
	}
}
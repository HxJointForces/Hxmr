package hxrm;

#if macro
import haxe.CallStack;
import haxe.macro.Context;
import haxe.macro.Expr;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using Lambda;
#end

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Hxrm
{

	static public var DYNAMIC_TYPE;
	
	// вызовется при холодной компиляции
	macro public static function build():Expr {
		
		trace("init " + firstStart);
		DYNAMIC_TYPE = Context.getType("Dynamic");
		if (firstStart) {
			firstStart = false;
			typeDefinitionFactory = new HxrmTypeDefinitionFactory();

			Context.registerModuleReuseCall(Context.getLocalClass().get().module, "hxrm.Hxrm.rebuild()");
			//Context.onMacroContextReused(reuse);
			Context.onTypeNotFound(onTypeNotFound);
		}
		
		return {expr:EBlock([]), pos:Context.currentPos()}; // нулл или 0 не стоит. т.к. это конкретный тип, а так Untyped<0>
	}
	
	#if macro
	
	private static var firstStart = true;
	private static var typeDefinitionFactory : HxrmTypeDefinitionFactory;

	// вызывается при повторной компиляции при закешированном контексте
	// но xml файлы могли и измениться, да и парсер обнуляется
	// и тут самое интересное, со второго ребилда парсер уже не обнуляется :)
	public static function rebuild() {
		
		//trace("rebuild");
		//trace(typeDefinitionFactory);
		DYNAMIC_TYPE = Context.getType("Dynamic");
		if (typeDefinitionFactory == null) {
			typeDefinitionFactory = new HxrmTypeDefinitionFactory();
		}
		else {
			typeDefinitionFactory.reset();
		}
		inProcess = new Map();
		nullTypes = new List<String>();
		Context.onTypeNotFound(onTypeNotFound);
	}
	
	static var inProcess:Map<String, Bool> = new Map<String, Bool>();
	static var nullTypes:List<String> = new List<String>();
	
	static function onTypeNotFound(t:String):TypeDefinition {
		
		if (t.startsWith("haxe")) return null;
		if (nullTypes.has(t)) return null;
		//trace('onTypeNotFound $t');
		var path = t.replace(".", "/") + ".xml";
		try {
			path = Context.resolvePath(path);
		} catch(e : Dynamic) {
			//trace(Std.string(e));
			nullTypes.push(t);
			return null;
		}
		if (inProcess.exists(t)) {
			trace(CallStack.toString(CallStack.callStack()));
			throw "overflow: " + t;
			return null;
		}
		inProcess[t] = true;
		
		try {
			return typeDefinitionFactory.createTypeDefinition(path, t);
		} catch(e : Dynamic) {
			trace(Std.string(e));
			nullTypes.push(t);
			return null;
		}
	}
	#end
}
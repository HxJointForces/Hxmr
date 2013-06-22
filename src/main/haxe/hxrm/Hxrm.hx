package hxrm;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
#end

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Hxrm
{
	
	// вызовется при холодной компиляции
	macro public static function build():Expr {
		
		trace("init " + firstStart);
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
		
		trace("rebuild");
		trace(typeDefinitionFactory);
		if (typeDefinitionFactory == null) {
			typeDefinitionFactory = new HxrmTypeDefinitionFactory();
		}
		else {
			typeDefinitionFactory.reset();
		}
		Context.onTypeNotFound(onTypeNotFound);
	}
	
	static function onTypeNotFound(t:String):TypeDefinition {
		
		if (t.startsWith("haxe")) return null;
		trace('onTypeNotFound $t');
		try {
			var path = t.replace(".", "/") + ".xml";
			path = Context.resolvePath(path);
			return typeDefinitionFactory.createTypeDefinition(path, t);
		} catch(e : Dynamic) {
			trace(Std.string(e));
			return null;
		}
	}
	#end
}
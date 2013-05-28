package hxrm;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hxrm.parser.IParser;
import hxrm.parser.Tools;
import hxrm.parser.mxml.MXMLParser;
import hxrm.writer.haxe.HaxeWriter;
import hxrm.writer.macro.TypeDefenitionWriter;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using hxrm.parser.Tools.FilePosUtils;
#end

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Hxrm
{
	#if macro
	
	static var firstStart = true;
	
	
	static function init() {
		if (parser == null) {
			parser = new MXMLParser();
			tdWriter = new TypeDefenitionWriter();
			#if debug
			haxeWriter = new HaxeWriter();
			#end
		}
	}
	
	static function reset() {
		parser.cleanCache(); // может стоит просто пересоздавать парсер
		tdWriter.cleanCache();
		#if debug
			haxeWriter.cleanCache();
			#end
	}
	
	static var parser:IParser;
	static var tdWriter:TypeDefenitionWriter;
	#if debug
	static var haxeWriter:HaxeWriter;
	#end
	
	// вызывается при повторной компиляции при закешированном контексте
	// но xml файлы могли и измениться, да и парсер обнуляется
	// и тут самое интересное, со второго ребилда парсер уже не обнуляется :)
	public static function rebuild() {
		
		trace("rebuild");
		trace(parser);
		if (parser == null) init();	else reset();
		
		Context.onTypeNotFound(onTypeNotFound);
	}
	
	/*public static function reuse() {
		return true;
	}*/
	
	#end

	// вызовется при холодной компиляции
	macro public static function build():Expr {
		
		trace("init " + firstStart);
		if (firstStart) {
			firstStart = false;
			
			Context.registerModuleReuseCall(Context.getLocalClass().get().module, "hxrm.Hxrm.rebuild()");
			//Context.onMacroContextReused(reuse);
			Context.onTypeNotFound(onTypeNotFound);
			
			init();
		}
		
		return {expr:EBlock([]), pos:Context.currentPos()}; // нулл или 0 не стоит. т.к. это конкретный тип, а так Untyped<0>
	}
	
	#if macro
	
	static function onTypeNotFound(t:String):TypeDefinition {
		
		if (t.startsWith("haxe")) return null;
		
		var path = t.replace(".", "/") + ".xml";
		path = Context.resolvePath(path);
		
		if (!FileSystem.exists(path)) {
			trace('xml file not found: $path'); // пока трейс. лучше убрать. пусть компилятор делает все сам
			return null;
		}
		
		trace(path);
		//trace(Xml.parse(File.getContent(path)));
		
		var node = null;
		
		try {
			node = parser.parse(File.getContent(path), path);
		} catch (e:ParserError) {
			Context.error(e.toString(), Context.makePosition(e.filePos.toMacroPosition()));
		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
		}
		
		if (node != null) {
			
			trace(node);
			var td = tdWriter.write(node);
			#if debug  
			// TODO: сделать принт в файлы по требованию из девайнов
			trace(haxeWriter.write(td));
			#end
			return td;
		}
		return null;
	}
	
	#end
}
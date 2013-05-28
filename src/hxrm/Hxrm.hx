package hxrm;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hxrm.parser.IParser;
import hxrm.parser.mxml.MXMLParser;
import hxrm.writer.TypeDefenitionWriter;
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
	#if macro
	
	static var firstStart = false;
	static var inited = false;
	
	static function init() {
		parser = new MXMLParser();
		tdWriter = new TypeDefenitionWriter();
		inited = true;
	}
	
	static function reset() {
		parser.cleanCache();
		inited = false;
	}
	
	
	static var parser:IParser;
	static var tdWriter:TypeDefenitionWriter;
	
	#end

	macro public static function build():Expr {
		
		if (firstStart) {
			firstStart = false;
			Context.onMacroContextReused(function () {
				reset(); // пересборка проекта. не уверен, но для халка мне пришлось делать ровно так, чтобы он вызвал заного макрос
				// надо тестить без и с этим onMacroContextReused
				return true;
			});
		}
		Context.onTypeNotFound(onTypeNotFound);
		
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
		
		if (!inited) {
			init();
		}
		
		trace(path);
		trace(Xml.parse(File.getContent(path)));
		
		var node = parser.parse(File.getContent(path), path);
		var td = tdWriter.write(node);
		
		return td;
	}
	
	#end
}
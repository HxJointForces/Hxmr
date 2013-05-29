package hxrm;

import haxe.macro.Context;
import haxe.macro.Expr;
import hxrm.parser.IParser;
import hxrm.parser.mxml.MXMLParser;
import hxrm.parser.Tools;
import hxrm.writer.haxe.HaxeWriter;
import hxrm.writer.macro.TypeDefenitionWriter;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using hxrm.parser.Tools.FilePosUtils;

class HxrmTypeDefinitionFactory {

	var parser:IParser;
	var tdWriter:TypeDefenitionWriter;
	#if debug
	static var haxeWriter:HaxeWriter;
	#end
	
	public function new() {
		parser = new MXMLParser();
		tdWriter = new TypeDefenitionWriter();
		#if debug
		haxeWriter = new HaxeWriter();
		#end
	}
	
	public function reset() {
		parser.cleanCache(); // может стоит просто пересоздавать парсер
		tdWriter.cleanCache();
		#if debug
		haxeWriter.cleanCache();
		#end
	}
	
	public function createTypeDefinition(path : String) : TypeDefinition
	{
		path = Context.resolvePath(path);

		if (!FileSystem.exists(path)) {
			trace('xml file not found: $path'); // пока трейс. лучше убрать. пусть компилятор делает все сам
			return null;
		}

		trace(path);
		//trace(Xml.parse(File.getContent(path)));

		var node = null;

		try {
			// We should not pass file to parser because parser can parse Strings instead of files
			node = parser.parse(File.getContent(path));
		} catch (e:ParserError) {
			Context.error(e.toString(), Context.makePosition(e.filePos.toMacroPosition()));
		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
		}

		if (node != null) {

			trace("\n" + node);
			var td = tdWriter.write(node);
			#if debug  
			// TODO: сделать принт в файлы по требованию из девайнов
			trace(haxeWriter.write(td));
			#end
			return td;
		}
		
		return null;
	}
}
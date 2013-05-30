package hxrm;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hxrm.parser.mxml.MXMLParser;
import hxrm.parser.Tools;
import hxrm.writer.macro.TypeDefenitionWriter;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using hxrm.parser.Tools.FilePosUtils;

/**
 * java developer был тут ))
 */
class HxrmTypeDefinitionFactory {

	var parser:MXMLParser;
	var tdWriter:TypeDefenitionWriter;
	
	#if debug
	var p:Printer;
	#end
	
	public function new() {
		parser = new MXMLParser();
		tdWriter = new TypeDefenitionWriter();
		
		#if debug
		p = new Printer();
		#end
	}
	
	public function reset() {
		parser.cleanCache(); // может стоит просто пересоздавать парсер
		tdWriter.cleanCache();
	}
	
	public function createTypeDefinition(path : String, type : String) : TypeDefinition
	{
		if (!FileSystem.exists(path)) {
			trace('xml file not found: $path'); // пока трейс. лучше убрать. пусть компилятор делает все сам
			return null;
		}

		trace(path);
		//trace(Xml.parse(File.getContent(path)));

		var node = null;

		try {
			node = parser.parse(File.getContent(path));
		} catch (e:ParserError) {
			Context.error(e.toString(), Context.makePosition(e.filePos.toMacroPosition(path)));
		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
		}

		var typeDefinition : TypeDefinition = null;
		if (node != null) {

			trace("\n" + node);
			typeDefinition = tdWriter.write(node, type, path);
			
			#if debug  
			// TODO: сделать принт в файлы по требованию из девайнов
			trace(p.printTypeDefinition(typeDefinition, true));
			#end
		}
		
		return typeDefinition;
	}
	
}
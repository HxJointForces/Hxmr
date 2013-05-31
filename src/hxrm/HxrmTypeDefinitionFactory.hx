package hxrm;

import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import hxrm.generator.macro.TypeDefenitionGenerator;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hxrm.parser.mxml.MXMLParser;
import hxrm.parser.Tools;
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
	var analyzer:NodeAnalyzer;
	var tdWriter:TypeDefenitionGenerator;
	
	#if debug
	var p:Printer;
	#end
	
	public function new() {
		parser = new MXMLParser();
		analyzer = new NodeAnalyzer();
		tdWriter = new TypeDefenitionGenerator();
		
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

		//trace(Xml.parse(File.getContent(path)));

		var node = null;

		try {
			node = parser.parse(File.getContent(path));
		} catch (e:ParserError) {
			Context.error(e.toString(), Context.makePosition(e.filePos.toMacroPosition(path)));
		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
			return null;
		}
		
		trace("\n" + node);
		
		var scope : NodeScope = null;
		try {
			scope = analyzer.analyze(node);
			trace(scope);
		} /*catch (e:ParserError) {
			Context.error(e.toString(), Context.makePosition(e.filePos.toMacroPosition(path)));
		} */catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
			return null;
		}

		var typeDefinition : TypeDefinition = null;
		if (scope != null) {

			typeDefinition = tdWriter.write(analyzer, scope, type, path);
			
			#if debug  
			// TODO: сделать принт в файлы по требованию из девайнов
			trace(p.printTypeDefinition(typeDefinition, true));
			#end
		}
		
		return typeDefinition;
	}
	
}
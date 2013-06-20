package hxrm;

import hxrm.HxmrContext.ContextError;
import hxrm.utils.TypeUtils;
import haxe.CallStack;
import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import hxrm.generator.macro.TypeDefenitionGenerator;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hxrm.parser.mxml.MXMLParser;
import hxrm.parser.Tools;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using hxrm.parser.Tools.FilePosUtils;

/**
 * 
 */
class HxrmTypeDefinitionFactory {

	var context : HxmrContext;

	var parser:MXMLParser;
	var analyzer:NodeAnalyzer;
	var tdWriter:TypeDefenitionGenerator;
	
	#if debug
	var p:Printer;
	#end
	
	public function new() {
		context = new HxmrContext();
		
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

		try {

			var node = parser.parse(context, File.getContent(path));
			
			if(checkErrors()) {
				return null;
			}
			
			trace("\n" + node);
			
			var scope : NodeScope = analyzer.analyze(context, node);

			if(checkErrors()) {
				return null;
			}
			
			#if bsideup
				TypeUtils.prettyPrintType(scope);
			#end
	
			var typeDefinition : TypeDefinition = tdWriter.write(context, scope, type, path);

			if(checkErrors()) {
				return null;
			}
				
			#if debug  
			// TODO: print to file on demand
			trace(p.printTypeDefinition(typeDefinition, true));
			#end

			return typeDefinition;

		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(CallStack.exceptionStack().join("\n"));
			trace(e);
		}
		
		return null;
	}

	private function checkErrors() : Bool {
		if(context.errors.length == 0) {
			return false;
		}
		
		for(e in context.errors) {
			trace(e);
		}
		return true;
	}
	
}
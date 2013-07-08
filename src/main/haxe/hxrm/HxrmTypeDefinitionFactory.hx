package hxrm;

import haxe.macro.Context;
import hxrm.HxmrContext.ContextError;
import hxrm.utils.TypeUtils;
import haxe.CallStack;
import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import hxrm.generator.TypeDefinitionGenerator;
import haxe.macro.Expr;
import haxe.macro.Printer;
import hxrm.parser.mxml.MXMLParser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * 
 */
class HxrmTypeDefinitionFactory {

	var context : HxmrContext;

	var parser:MXMLParser;
	var analyzer:NodeAnalyzer;
	var tdWriter:TypeDefinitionGenerator;
	
	#if debug
	var p:Printer;
	#end
	
	public function new() {
		context = new HxmrContext();
		
		parser = new MXMLParser();
		analyzer = new NodeAnalyzer();
		tdWriter = new TypeDefinitionGenerator();
		
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
		
		var local = Context.getLocalClass();
		if (local != null)
			Context.registerModuleDependency(local.get().module, path);

		try {

			var node = parser.parse(context, File.getContent(path));
			
			if(checkErrors(path)) {
				return null;
			}
			
			#if debug
			trace("\n" + node);
			#end
			
			var scope : NodeScope = analyzer.analyze(context, node);

			if(checkErrors(path)) {
				return null;
			}
			
			#if bsideup
				TypeUtils.prettyPrintType(scope);
			#end
	
			var typeDefinition : TypeDefinition = tdWriter.write(context, scope, type, path);

			if(checkErrors(path)) {
				return null;
			}
				
			#if debug  
			// TODO: print to file on demand
			trace(p.printTypeDefinition(typeDefinition, true));
			#end

			return typeDefinition;

		} catch (e:Dynamic) {
			//Lib.rethrow(e); // Interp.Runtime(_)
			trace(e);
			trace(CallStack.exceptionStack().join("\n"));
		}
		
		return null;
	}

	private function checkErrors(file:String) : Bool {
		if(context.errors.length == 0) {
			return false;
		}
		
		for(e in context.errors) {
			trace(e);
			e.nativeThrow(file); // TODO: test multiple errors
		}
		return true;
	}
	
}
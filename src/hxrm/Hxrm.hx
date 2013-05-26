package hxrm;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
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

	macro public static function build():Expr {
		
		Context.onTypeNotFound(onTypeNotFound);
		
		return macro null;
	}
	
	#if macro
	
	static function onTypeNotFound(t:String):TypeDefinition {
		
		if (t.startsWith("haxe")) return null;
		
		var path = t.replace(".", "/") + ".xml";
		path = Context.resolvePath(path);
		
		if (!FileSystem.exists(path)) {
			trace('xml file not found: $path');
			return null;
		}
		
		trace(path);
		trace(Xml.parse(File.getContent(path)));
		
		return null;
		
	}
	
	#end
}
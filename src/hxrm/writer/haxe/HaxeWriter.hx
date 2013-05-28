package hxrm.writer.haxe;
import haxe.macro.Expr;
import haxe.macro.Printer;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class HaxeWriter
{
	var p:Printer;

	public function new() 
	{
		p = new Printer();
	}
	
	public function write(td:TypeDefinition):String {
		
		return p.printTypeDefinition(td, true);
	}
	
	public function cleanCache():Void
	{
		
	}
	
}
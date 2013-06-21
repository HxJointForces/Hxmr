package hxrm.generator;

import haxe.macro.Expr;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class GeneratorScope {
	
	public var typeDefinition:TypeDefinition;
	
	public var ctor:Field;
	public var ctorExprs:Array<Expr>;
	
	public function new(tp:TypeDefinition) {
		
		this.typeDefinition = tp;
	}
}
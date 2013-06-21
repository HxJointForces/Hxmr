package hxrm.generator;

import haxe.macro.Expr;
import hxrm.analyzer.NodeScope;
import hxrm.HxmrContext;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class GeneratorContext
{
	public var hxmrContext:HxmrContext;
	//public var generator:TypeDefinitionGenerator;
	public var node:NodeScope;
	
	public var pos:Position; // pos must be read from NodeScope
	
	public function new(hxmrContext:HxmrContext, node:NodeScope) {
		this.hxmrContext = hxmrContext;
		this.node = node;
	}
}
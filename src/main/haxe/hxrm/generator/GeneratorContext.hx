package hxrm.generator;

import haxe.macro.Expr;
import hxrm.analyzer.NodeScope;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class GeneratorContext
{
	public var node:NodeScope;
	
	public var pos:Position; // pos must be read from NodeScope
	
	public function new(node:NodeScope) {
		this.node = node;
	}
}
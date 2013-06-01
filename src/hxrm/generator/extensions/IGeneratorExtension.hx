package hxrm.generator.extensions;

import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;

interface IGeneratorExtension {

	function generate(scope:NodeScope, type:TypeDefinition, pos : Position) : Bool;

}

package hxrm.generator.extensions;

import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;

interface IGeneratorExtension {

	function generate(context:GeneratorContext, scope:GeneratorScope) : Bool;

}

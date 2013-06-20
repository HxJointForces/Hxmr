package hxrm.generator.extensions;

import hxrm.generator.TypeDefenitionGenerator;
import hxrm.analyzer.NodeAnalyzer;
import hxrm.analyzer.NodeScope;
import haxe.macro.Expr;
import haxe.macro.Expr;

class GeneratorExtensionBase implements IGeneratorExtension {

	private var generator : TypeDefenitionGenerator;

	public function new(generator : TypeDefenitionGenerator) {
		this.generator = generator;
	}

	public function generate(scope:NodeScope, type:TypeDefinition, pos : Position) : Bool {
		return false;
	}

}

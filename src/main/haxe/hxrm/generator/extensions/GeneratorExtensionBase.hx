package hxrm.generator.extensions;

import haxe.macro.Expr;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;
import hxrm.generator.TypeDefenitionGenerator;

class GeneratorExtensionBase implements IGeneratorExtension {
	
	var generator:TypeDefenitionGenerator;

	public function new(generator:TypeDefenitionGenerator) {
		this.generator = generator;
	}

	public function generate(context:GeneratorContext, scope:GeneratorScope) : Bool {
		return false;
	}

}

package hxrm.generator.extensions;

import haxe.macro.Expr;
import hxrm.generator.GeneratorContext;
import hxrm.generator.GeneratorScope;
import hxrm.generator.TypeDefinitionGenerator;
import hxrm.HxmrContext;

class GeneratorExtensionBase implements IGeneratorExtension {
	
	var generator:TypeDefinitionGenerator;

	public function new(generator:TypeDefinitionGenerator) {
		this.generator = generator;
	}

	public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
		return false;
	}

}

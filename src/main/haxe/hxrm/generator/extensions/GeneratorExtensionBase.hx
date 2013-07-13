package hxrm.generator.extensions;

import hxrm.generator.GeneratorScope;
import hxrm.HxmrContext;

class GeneratorExtensionBase implements IGeneratorExtension {
	
	public function new() {
	}

	public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
		return false;
	}

}

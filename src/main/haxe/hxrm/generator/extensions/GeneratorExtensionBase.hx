package hxrm.generator.extensions;

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

	function getCtor(type:TypeDefinition) : Field {
		for(field in type.fields) {
			if(field.name == "new") {
				return field;
			}
		}
		return null;
	}

}

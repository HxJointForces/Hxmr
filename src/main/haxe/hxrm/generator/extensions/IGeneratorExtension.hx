package hxrm.generator.extensions;

import hxrm.generator.GeneratorScope;

interface IGeneratorExtension {

	function generate(context:HxmrContext, scope:GeneratorScope) : Bool;

}

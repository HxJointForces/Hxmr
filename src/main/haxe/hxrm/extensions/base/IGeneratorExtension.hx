package hxrm.extensions.base;

import hxrm.generator.GeneratorScope;
import hxrm.HxmrContext;

interface IGeneratorExtension {

	function generate(context:HxmrContext, scope:GeneratorScope) : Bool;

}

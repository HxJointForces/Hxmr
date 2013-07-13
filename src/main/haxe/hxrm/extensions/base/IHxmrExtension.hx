package hxrm.extensions.base;
import hxrm.generator.GeneratorScope;
import hxrm.analyzer.NodeScope;
interface IHxmrExtension {

    // return true if it needs one more iteration
    function analyze(context : HxmrContext, scope : NodeScope) : Bool;

    // return true if it needs one more iteration
    function generate(context:HxmrContext, scope:GeneratorScope) : Bool;

}

package hxrm.extensions.base;

import hxrm.generator.GeneratorScope;
import hxrm.analyzer.NodeScope;

class GenerativeExtensionBase<T : (INodeAnalyzerExtension), K : (IGeneratorExtension)> implements IHxmrExtension {

    public var analyzer : T;

    public var generator : K;

    public function new() {
        //analyzer = new T();
        //generator = new K();
    }

    public function analyze(context : HxmrContext, scope : NodeScope) : Bool {
        return analyzer.analyze(context, scope);
    }

    public function generate(context:HxmrContext, generatorScope:GeneratorScope) : Bool {
        return generator.generate(context, generatorScope);
    }
}
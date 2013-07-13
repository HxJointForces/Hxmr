package hxrm.extensions.base;

import hxrm.generator.GeneratorScope;
import hxrm.analyzer.NodeScope;

class GenerativeExtensionBase<A : (INodeAnalyzerExtension), G : (IGeneratorExtension)> implements IHxmrExtension {

    public var analyzer : A;

    public var generator : G;

    public function new () {
        //analyzer = cast Type.createInstance(A, []);
        //generator = cast Type.createInstance(G, []);
    }

    public function analyze(context : HxmrContext, scope : NodeScope) : Bool {
        return analyzer.analyze(context, scope);
    }

    public function generate(context:HxmrContext, scope:GeneratorScope) : Bool {
        return generator.generate(context, scope);
    }
}

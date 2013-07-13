package hxrm.extensions.basicType;

import hxrm.extensions.base.GenerativeExtensionBase;

class BasicTypeExtension extends GenerativeExtensionBase<BasicTypeAnalyzerExtension, BasicTypeGeneratorExtension> {

    public function new() {
        analyzer = new BasicTypeAnalyzerExtension();
        generator = new BasicTypeGeneratorExtension();
        super();
    }

}

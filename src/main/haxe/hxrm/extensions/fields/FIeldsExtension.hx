package hxrm.extensions.fields;

import hxrm.extensions.base.GenerativeExtensionBase;

class FIeldsExtension extends GenerativeExtensionBase<FieldsAnalyzerExtension, FieldsGeneratorExtension> {

    public function new() {
        analyzer = new FieldsAnalyzerExtension();
        generator = new FieldsGeneratorExtension();
        super();
    }
}

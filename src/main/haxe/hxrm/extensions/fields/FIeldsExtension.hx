package hxrm.extensions.fields;

import hxrm.extensions.base.GenerativeExtensionBase;

class FieldsExtension extends GenerativeExtensionBase<FieldsAnalyzerExtension, FieldsGeneratorExtension> {

    public function new() {
        analyzer = new FieldsAnalyzerExtension();
        generator = new FieldsGeneratorExtension();
        super();
    }
}

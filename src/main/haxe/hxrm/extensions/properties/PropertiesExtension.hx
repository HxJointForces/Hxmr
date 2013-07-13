package hxrm.extensions.properties;

import hxrm.extensions.base.GeneratorExtensionBase;
import hxrm.extensions.base.GenerativeExtensionBase;

class PropertiesExtension extends GenerativeExtensionBase<PropertiesAnalyzerExtension, PropertiesGeneratorExtension> {

    public function new() {
        analyzer = new PropertiesAnalyzerExtension();
        generator = new PropertiesGeneratorExtension();
        super();
    }

}

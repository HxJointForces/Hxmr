package hxrm.extensions.properties.initializers;

import hxrm.parser.mxml.MXMLNode;
class Itor<T> {
    public var value : T;

    public var node : MXMLNode;

    public function new(value : T, node : MXMLNode) {
        this.value = value;
        this.node = node;
    }

    public function toString() : String {
        var valueTypeName : String = Type.getClassName(Type.getClass(value));
        return 'Itor(value = "$valueTypeName")';
    }
}

package hxrm.analyzer.initializers;

class Itor<T> {
    public var value : T;

    public function new(value : T) {
        this.value = value;
    }

    public function toString() : String {
        return 'Itor(value = "$value")';
    }
}

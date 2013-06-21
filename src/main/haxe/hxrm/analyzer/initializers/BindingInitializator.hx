package hxrm.analyzer.initializers;

class BindingInitializator {

	public var value : Dynamic;

	public var fieldName : String;

	public function new(fieldName : String, value : Dynamic) {
		this.fieldName = fieldName;
		this.value = value;
	}

	public function toString() : String {
		return 'BindingInitializator(value = "$value")';
	}

}

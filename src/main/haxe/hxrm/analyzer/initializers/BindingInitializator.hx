package hxrm.analyzer.initializers;

class BindingInitializator {

	public var value : String;

	public var fieldName : String;

	public function new(fieldName : String, value : String) {
		this.fieldName = fieldName;
		this.value = value;
	}

	public function toString() : String {
		return 'BindingInitializator(value = "$value")';
	}

}

package hxrm.analyzer.initializers;

class BindingInitializator {

	public var value : String;

	public function new(value : String) {
		this.value = value;
	}

	public function toString() : String {
		return 'BindingInitializator(value = "$value")';
	}

}

package hxrm.analyzer.initializers;

import haxe.macro.Type;

class FieldInitializator extends BindingInitializator {

	public var fieldType : Type;

	public function new(fieldName : String, scope : Dynamic, fieldType : Type) {
		super(fieldName, scope);
		this.fieldType = fieldType;
	}

	override public function toString() : String {
		return 'NodeScopeInitializator(scope = $value)';
	}

}

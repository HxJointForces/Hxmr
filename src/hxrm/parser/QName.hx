package hxrm.parser;
class QName {
	
	public var namespace : String;
	public var localPart : String;
	
	public function new(namespace : String, localPart : String) {
		this.namespace = namespace == null ? "*" : namespace;
		this.localPart = localPart;
	}

	public function toString() : String {
		return '$namespace:$localPart';
	}

	public function toHaxeTypeId() : String {
		return if(namespace == "*") localPart;
				else '$namespace.$localPart';
	}
}

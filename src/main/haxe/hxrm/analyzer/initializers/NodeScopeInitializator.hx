package hxrm.analyzer.initializers;

import hxrm.parser.mxml.MXMLQName;
class NodeScopeInitializator {

	public var id : String;
	public var scope : NodeScope;
	public function new(scope : NodeScope) {
		this.scope = scope;
		this.id = scope.context.node.attributes.get(new MXMLQName(MXMLQName.ASTERISK, "id"));
		
		if(this.id == null) {
			// TODO dirty dirty hack and should be removed:)
			this.id = Std.string(Std.random(100000));
		}
	}

	public function toString() : String {
		return 'NodeScopeInitializator(scope = $scope)';
	}

}

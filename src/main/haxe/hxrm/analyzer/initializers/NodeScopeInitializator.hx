package hxrm.analyzer.initializers;

import hxrm.parser.mxml.MXMLQName;
class NodeScopeInitializator {

	public var id : String;
	public var scope : NodeScope;
	public function new(id : String, scope : NodeScope) {
		this.id = id;
		this.scope = scope;
	}

	public function toString() : String {
		return 'NodeScopeInitializator(scope = $scope)';
	}

}

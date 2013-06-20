package hxrm.analyzer.initializers;

class NodeScopeInitializator {

	public var scope : NodeScope;
	public function new(scope : NodeScope) {
		this.scope = scope;
	}

	public function toString() : String {
		return 'NodeScopeInitializator(scope = $scope)';
	}

}

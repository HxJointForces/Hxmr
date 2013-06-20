package hxrm.analyzer.initializers;

enum IInitializator {
	InitBinding(initializator:BindingInitializator);
	InitNodeScope(initializator:NodeScopeInitializator);
}

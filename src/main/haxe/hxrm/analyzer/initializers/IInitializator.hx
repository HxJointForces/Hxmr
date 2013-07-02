package hxrm.analyzer.initializers;

enum IInitializator {
	InitBinding(initializator:BindingInitializator);
	InitField(initializator:FieldInitializator);
}

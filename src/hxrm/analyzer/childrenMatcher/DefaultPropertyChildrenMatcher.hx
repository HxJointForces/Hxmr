package hxrm.analyzer.childrenMatcher;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
class DefaultPropertyChildrenMatcher extends ChildrenMatcherBase {

	public function new(analyzer : NodeAnalyzer) {
		super(analyzer);
	}

	override public function match(scope:NodeScope, child:MXMLNode):Void {
	
		var childScope : NodeScope = analyzer.analyze(child, scope);
		
		if(childScope != null) {
			scope.children.push(childScope);
		}
	}


}

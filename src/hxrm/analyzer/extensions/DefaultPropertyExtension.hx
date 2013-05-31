package hxrm.analyzer.extensions;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
class DefaultPropertyExtension extends NodeAnalyzerExtensionBase {

	override public function matchChild(scope:NodeScope, child:MXMLNode):Void {
	
		return super.matchChild(scope, child);
		var childScope : NodeScope = analyzer.analyze(child, scope);
		
		if(childScope != null) {
			scope.children.push(childScope);
		} else {
			super.matchChild(scope, child);
		}
	}


}

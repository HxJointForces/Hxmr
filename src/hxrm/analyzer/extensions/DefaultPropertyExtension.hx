package hxrm.analyzer.extensions;
import StringTools;
import hxrm.analyzer.NodeScope;
import hxrm.parser.mxml.MXMLNode;
class DefaultPropertyExtension extends NodeAnalyzerExtensionBase {

	override public function matchChild(scope:NodeScope, child:MXMLNode):Bool {
	
		if(StringTools.startsWith(child.namespaces.get(child.name.namespace), "http://")) {
			return super.matchChild(scope, child);
		}
		
		var childScope : NodeScope = analyzer.analyze(child);
		
		if(childScope == null) {
			return super.matchChild(scope, child);
		}
		
		scope.children.push(childScope);
		return false;
	}


}

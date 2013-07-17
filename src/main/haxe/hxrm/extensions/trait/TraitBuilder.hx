package hxrm.extensions.trait;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import hxrm.analyzer.QName;
import hxrm.analyzer.QNameUtils;
import hxrm.utils.TypeUtils;

using haxe.macro.Tools;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TraitBuilder
{

	static public function build() {
		var res:Array<Field> = Context.getBuildFields();
		
		var typeRef = Context.getLocalClass();
		var type = typeRef.get();
		var typeQName = QNameUtils.fromModuleAndName(type.module, type.name);
		
		trace(typeQName);
		
		for (a in res) {
			TypeUtils.prettyPrintType(a.kind);
		}
		
		
		
		
		
		return [];
	}
	
}
package hxrm.generator;

import hxrm.extensions.base.IHxmrExtension;
import hxrm.extensions.properties.PropertiesGeneratorExtension;
import haxe.macro.Printer;
import hxrm.HxmrContext;
import hxrm.utils.TypeUtils;
import hxrm.extensions.basicType.BasicTypeGeneratorExtension;
import hxrm.extensions.base.IGeneratorExtension;
import hxrm.analyzer.QNameUtils;
import hxrm.analyzer.NodeScope;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import hxrm.analyzer.QName;

using StringTools;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class TypeDefinitionGeneratorError extends ContextError {
	
}
 
class TypeDefinitionGenerator
{
	public function new() 
	{
	}
	
	public function write(context : HxmrContext, nodeScope:NodeScope, type:String, file:String):TypeDefinition {

		var pos : Position = Context.makePosition( { min:0, max:0, file:file } );
		var qName : QName = QNameUtils.fromHaxeTypeId(type);
		
		var typeDefinition : TypeDefinition =  {
			pack: qName.packageNameParts,
			name: qName.className,
			pos: pos,
			meta: [],
			params: [],
			isExtern: false,
			kind: TDClass(getTypePath(nodeScope.type), null, false),
			fields:[]
		}
		
		var scope = new GeneratorScope(typeDefinition);
		
		scope.context = new GeneratorContext(nodeScope);
		scope.context.pos = pos; //TODO remove
		

		var currentIterationExtensions = context.extensions.iterator();

		while(currentIterationExtensions.hasNext()) {
			var nextIterationExtensions : Array<IHxmrExtension> = [];

			for(extension in currentIterationExtensions) {
				if(extension.generate(context, scope)) {
					nextIterationExtensions.push(extension);
				}
			}
			currentIterationExtensions = nextIterationExtensions.iterator();
		}
		
		//TypeUtils.prettyPrintType(typeDefinition);
		
		#if debug
		//trace("\n" + (new Printer("   ")).printTypeDefinition(typeDefinition, true));
		#end
		
		return typeDefinition;
	}
	
	public function cleanCache():Void {
		
	}

	function getTypePath(t:Type):TypePath {
		var ct = Context.toComplexType(t);
		if (ct == null) throw "can't get CT of " + t;
		
		switch (ct) {
			case TPath(p): return p;
			case _:
				throw "can't get TypePath of " + t + " (" + ct + ")";
		}
	}
	
}
package hxrm.generator;

import hxrm.HxmrContext;
import hxrm.utils.TypeUtils;
import hxrm.generator.extensions.ConstructorGeneratorExtension;
import hxrm.generator.extensions.InitializersGeneratorExtension;
import hxrm.generator.extensions.IGeneratorExtension;
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
class TypeDefenitionGenerator
{
	private var extensions : Array<IGeneratorExtension>;
	
	public function new() 
	{
		extensions = [new InitializersGeneratorExtension(this), new ConstructorGeneratorExtension(this)];
	}
	
	
	public function write(context : HxmrContext, scope:NodeScope, type:String, file:String):TypeDefinition {
		trace('write:$type');

		var pos : Position = Context.makePosition( { min:0, max:0, file:file } );
		var qName : QName = QNameUtils.fromHaxeTypeId(type);
		
		var typeDefinition : TypeDefinition =  {
			pack: qName.packageNameParts,
			name: qName.className,
			pos: pos,
			meta: [],
			params: [],
			isExtern: false,
			kind: TDClass(getTypePath(scope.type), null, false),
			fields:[]
		}

		var currentIterationExtensions = extensions;

		while(currentIterationExtensions.length != 0) {
			var nextIterationExtensions : Array<IGeneratorExtension> = [];

			for(extension in currentIterationExtensions) {
				if(extension.generate(scope, typeDefinition, pos)) {
					nextIterationExtensions.push(extension);
				}
			}
			currentIterationExtensions = nextIterationExtensions;
		}
		
		TypeUtils.prettyPrintType(typeDefinition);
		
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
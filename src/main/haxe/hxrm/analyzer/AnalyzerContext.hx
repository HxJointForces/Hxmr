package hxrm.analyzer;

import hxrm.HxmrContext.Pos;
import hxrm.parser.mxml.MXMLQNameUtils;
import hxrm.parser.mxml.MXMLQName;
import hxrm.parser.mxml.MXMLNode;
import hxrm.parser.mxml.MXMLQName;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Type;
import hxrm.analyzer.NodeAnalyzer.NodeAnalyzerError;

enum AnalyzerContextErrorType {
	UNKNOWN_TYPE(type:String);
}

class AnalyzerContextError extends NodeAnalyzerError {
	public function new(type : AnalyzerContextErrorType, ?pos : Pos) {
		super(type, pos);
	}
}
// TODO: inject hxmrContext here
class AnalyzerContext {

	public var node : MXMLNode;

	public function new(node : MXMLNode) {
		this.node = node;
	}

	public inline function getClassType(type : Type) : ClassType {
		return switch (type) {
			case TInst(t, params):
				t.get();
			case _:
				throw "unsupported type: " + type;
		}
	}

	public function getType(typeQName:QName):Type {
		var type = null;
		try {
			//trace("getType: " + typeQName.toHaxeTypeId());
			type = Context.getType(typeQName.toHaxeTypeId());
		} catch (e:Dynamic) {
			trace(e);
			throw "can't find type: " + typeQName;
		}
		return type;
	}

	public function resolveQName(mxmlQName : MXMLQName):QName {

		var resolvedPackageNameParts : Array<String> = QNameUtils.splitPackage(MXMLQNameUtils.resolveNamespaceValue(node, mxmlQName.namespace));

		if(resolvedPackageNameParts != null && resolvedPackageNameParts.length > 0) {
			if(resolvedPackageNameParts[resolvedPackageNameParts.length - 1] == MXMLQName.ASTERISK) {
				resolvedPackageNameParts.pop();
			}
		}

		// <flash.display.Sprite /> support
		var localQName : QName = QNameUtils.fromHaxeTypeId(mxmlQName.localPart);

		// concat return new array
		//TODO Namespace.isNotEmpty method
		if(QNameUtils.packageNameIsEmpty(localQName.packageNameParts)) {
			resolvedPackageNameParts = resolvedPackageNameParts.concat(localQName.packageNameParts);
		}

		return new QName(resolvedPackageNameParts, localQName.className);
	}
}

package ;

import h2d.Interactive;
import h2d.RenderContext;
import h3d.Engine;
import h3d.System.Cursor;
import traits.ITrait;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface CheckBoxViewTrait extends ITrait
{

	
	override private function onAlloc():Void {
		super.onAlloc();
		
		cb.onChange = this.onChange;
		
		Reflect.setField(this, "checked", cb.checked);
	}
	
	public var checked(default, set):Bool;
	
	private function set_checked(value:Bool):Bool {
		return cb.checked = value;
	}
	
	public dynamic function onChange(b:Bool):Void {
		
	}
	
	
}
package ;

import h2d.comp.Button;
import h2d.comp.Checkbox;
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
		
		try {
			var c:Checkbox = cb;
		} catch (e:Button) {}
		
		cb.onChange = this.onChange;
	}
	
	public var checked(get, set):Bool;
	
	private function get_checked():Bool return cb.checked;
	private function set_checked(v:Bool):Bool return cb.checked = v;
	
	public var label(get, set):String;
	
	private function get_label():String return lbl.text;
	private function set_label(v:String):String return lbl.text = v;
	
	
	public dynamic function onChange(b:Bool):Void {}
}
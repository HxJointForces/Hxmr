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

	
	override private function sync(ctx:RenderContext):Void {
		super.sync(ctx);
		trace(ctx);
	}
	
	public function test():Void {
		//super.scaleX = 1;
		var t = new Interactive(10, 10);
		t.cursor = Cursor.Button;
		//trace(Engine.getCurrent().mem.stats());
		t.backgroundColor = 0xFFFF0000;
		this.addChild(t);
	}
	
	
	static private function is<T:Interactive>(a:T):Bool {
		return true;
	}
	
	
}
package ;

import h2d.Interactive;
import h2d.RenderContext;
import traits.ITrait;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface CheckBoxViewTrait extends ITrait
{

	
	/*override private function sync(ctx:RenderContext):Void {
		super.sync(ctx);
		trace(ctx);
	}*/
	
	public function test():Void {
		super.scaleX = 1;
		//new Interactive(10, 10);
	}
	
}
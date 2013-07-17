package ;
import flash.events.Event;
import flash.Lib;
import h2d.Font;
import h2d.Scene;
import h2d.Text;
import h3d.Engine;
import hxrm.Hxrm;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class H3DTest1
{

	static function main() {
		
		Hxrm.build();
		
		new H3DTest1();
	}
	
	var engine:Engine;
	var scene:Scene;
	
	public function new() {
		engine = new Engine();
		engine.onReady = init;
		engine.init();
		
	}
	
	function init() {
		scene = new Scene();
		
		var view = new CheckBoxView();
		scene.addChild(view);
		view.test();
		//CheckBoxView.test();
		
		Lib.current.addEventListener(Event.ENTER_FRAME, function (_) {
			engine.render(scene);
			scene.checkEvents();
		});
	}
	
}
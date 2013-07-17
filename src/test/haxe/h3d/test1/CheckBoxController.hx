package ;
import h2d.comp.Box;
import h2d.comp.Checkbox;
import h2d.comp.Component;
import h2d.comp.Label;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
private typedef ViewType = { cb:Checkbox, lbl:Label }

class CheckBoxController
{
	public var view(default, set):ViewType;
	
	function set_view(v:ViewType):ViewType {
		this.view = v;
		
		return v;
	}
	
	public function new() 
	{
	}
	
}
package ;
import h2d.comp.Box;
import h2d.comp.Checkbox;
import h2d.comp.Component;
import h2d.comp.Label;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
private typedef ViewType = CheckboxView; //{ cb:Checkbox, lbl:Label }

class CheckBoxController
{
	public var view(default, set):ViewType;
	
	function set_view(v:ViewType):ViewType {
		this.view = v;
		
		v.cb.onChange = function (s:Bool) {
			v.lbl.text = s ? "Checked" : "Unchecked";
		}
		
		v.cb.onChange(v.cb.checked);
		return v;
	}
	
	public function new() 
	{
	}
	
}
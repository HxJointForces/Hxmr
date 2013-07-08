package ;
import hxrm.utils.TypeUtils;
import hxrm.Hxrm;


/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Main 
{
	
	static function main() 
	{
		
		Hxrm.build();
		
		
		var a = new ml.Test();
		
		trace(a.aString);
		
		//TypeUtils.prettyPrintType(a); stack overflow!
		//trace(a);
		//trace(a.test2);
		trace(a != null);
		trace(a.test2);
	}
	
}

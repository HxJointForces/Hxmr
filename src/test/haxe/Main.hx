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
		
		TypeUtils.prettyPrintType(a.children);
	}
	
}

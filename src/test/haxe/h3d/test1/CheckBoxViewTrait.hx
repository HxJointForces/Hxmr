package ;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class CheckBoxViewTrait
{

	public var cb2:Int = 10;
	
	public var i(default, set):Int = 10;
	
	inline function set_i(v) {
		return i = v;
	}
	
	static var ABC:String = "abc";
	
	static inline var CC = true;
	
	public static function test() {
		trace("tada");
	}
	
}
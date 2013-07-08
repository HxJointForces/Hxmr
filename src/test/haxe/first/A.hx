package ;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
import deep.B;
class A
{
	public var aString:String;

	public var innerString : String;

	public var anotherInnerString : String;
	
	public var innerInt:Int = 0;
	
	@hxmrDefaultProperty public var children : Array<B>;

	public function new()
	{
		innerString = "start";
	}
	
}
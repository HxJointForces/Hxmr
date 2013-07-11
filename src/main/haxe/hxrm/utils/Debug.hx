package hxrm.utils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;



/**
* Various utils for debugging
*
*/
class Debug {


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Trace expressions (run-time value) if specified conditional compilation 
    * flag and 'debug' are defined 
    *
    * @param e     - expression, runtime value of which should be traced
    * @param cflag - conditional compilation flag to control, whether trace
    *                should be called
    */
    macro static public function print (e:Expr, ?cflag:Expr) : Expr {
        var debug : Bool = Context.defined('debug');
        if( !debug ) return macro true;

        switch (cflag.expr) {
            case EConst(CIdent(flag)):
                if( flag == "null" || Context.defined(flag) ){
                    return macro trace($e);
                }
            case _: 
                Context.error(
                    "Debug.print(): flag should be a constant identifier; given: " + ExprTools.toString(cflag), 
                    Context.currentPos()
                );                
        }

        return macro true;
    }//function print()

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Debug
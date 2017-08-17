package org.as3commons.asblocks.parser.core
{

import com.ericfeminella.collections.HashMap;
import com.ericfeminella.collections.IMap;

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.api.Operators;

public class AS3ParserMap
{
	public static var additive:IMap;
	
	public static var assignment:IMap;
	
	public static var equality:IMap;
	
	public static var relation:IMap;
	
	public static var shift:IMap;
	
	public static var multiplicative:IMap;
	
	private static var initialized:Boolean = maps();
	
	private static function maps():Boolean
	{
		if (initialized)
			return true;
		
		additive = new HashMap();
		additive.put(Operators.PLUS, AS3NodeKind.PLUS);
		additive.put(Operators.MINUS, AS3NodeKind.MINUS);
		
		assignment = new HashMap();
		assignment.put(Operators.ASSIGN, AS3NodeKind.ASSIGN);
		assignment.put(Operators.STAR_ASSIGN, AS3NodeKind.STAR_ASSIGN);
		assignment.put(Operators.DIV_ASSIGN, AS3NodeKind.DIV_ASSIGN);
		assignment.put(Operators.MOD_ASSIGN, AS3NodeKind.MOD_ASSIGN);
		assignment.put(Operators.PLUS_ASSIGN, AS3NodeKind.PLUS_ASSIGN);
		assignment.put(Operators.MINUS_ASSIGN, AS3NodeKind.MINUS_ASSIGN);
		assignment.put(Operators.SL_ASSIGN, AS3NodeKind.SL_ASSIGN);
		assignment.put(Operators.SR_ASSIGN, AS3NodeKind.SR_ASSIGN);
		assignment.put(Operators.BSR_ASSIGN, AS3NodeKind.BSR_ASSIGN);
		assignment.put(Operators.BAND_ASSIGN, AS3NodeKind.BAND_ASSIGN);
		assignment.put(Operators.BXOR_ASSIGN, AS3NodeKind.BXOR_ASSIGN);
		assignment.put(Operators.BOR_ASSIGN, AS3NodeKind.BOR_ASSIGN);
		assignment.put(Operators.LAND_ASSIGN, AS3NodeKind.LAND_ASSIGN);
		assignment.put(Operators.LOR_ASSIGN, AS3NodeKind.LOR_ASSIGN);
		
		equality = new HashMap();
		equality.put(Operators.EQUAL, AS3NodeKind.EQUAL);
		equality.put(Operators.NOT_EQUAL, AS3NodeKind.NOT_EQUAL);
		equality.put(Operators.STRICT_EQUAL, AS3NodeKind.STRICT_EQUAL);
		equality.put(Operators.STRICT_NOT_EQUAL, AS3NodeKind.STRICT_NOT_EQUAL);
		
		relation = new HashMap();
		relation.put(KeyWords.IN, AS3NodeKind.IN);
		relation.put(Operators.LT, AS3NodeKind.LT);
		relation.put(Operators.LE, AS3NodeKind.LE);
		relation.put(Operators.GT, AS3NodeKind.GT);
		relation.put(Operators.GE, AS3NodeKind.GE);
		relation.put(KeyWords.IS, AS3NodeKind.IS);
		relation.put(KeyWords.AS, AS3NodeKind.AS);
		relation.put(KeyWords.INSTANCE_OF, AS3NodeKind.INSTANCE_OF);
		
		shift = new HashMap();
		shift.put(Operators.SL, AS3NodeKind.SL);
		shift.put(Operators.SR, AS3NodeKind.SR);
		shift.put(Operators.SSL, AS3NodeKind.SSL);
		shift.put(Operators.BSR, AS3NodeKind.BSR);
		
		multiplicative = new HashMap();
		multiplicative.put(Operators.STAR, AS3NodeKind.STAR);
		multiplicative.put(Operators.DIV, AS3NodeKind.DIV);
		multiplicative.put(Operators.MOD, AS3NodeKind.MOD);
		
		return true;
	}
}
}
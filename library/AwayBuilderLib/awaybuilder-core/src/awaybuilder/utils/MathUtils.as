package awaybuilder.utils 
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author CornFlex
	 */	
	public class MathUtils
	{	
		
		public static function convertToRadian(angle:Number):Number
		{
			return angle * Math.PI / 180;
		}
		
		public static function convertToDegree(angle:Number):Number
		{
			return 180 * angle / Math.PI;
		}	
		
		public static function getVector3DFromUV(uv:Point, radius:Number, bitmapWidth:Number, bitmapHeight:Number):Object 
		{
			var degreesX:Number = (uv.y * 180) / bitmapHeight;
			degreesX = degreesX - 90;
			degreesX = degreesX * -1;
			
			var degreesY:Number = (uv.x * 360) / bitmapWidth;			
			
			var radianX:Number = MathUtils.convertToRadian(degreesX);
			var radianY:Number = MathUtils.convertToRadian(degreesY);			
			
			var xcoordinate:Number = (radius * Math.cos(radianX)) * Math.cos(radianY);
			var ycoordinate:Number = radius * Math.sin(radianX);
			var zcoordinate:Number = (radius * Math.cos(radianX)) * Math.sin(radianY);
			
			return { x:xcoordinate, y:ycoordinate, z:zcoordinate, rotationX:degreesX, rotationY:degreesY };
		}				
		
		public static function getMillerProjectionPoint(long:Number, lat:Number, mapWith:Number, mapHeight:Number):Point
		{
			var point:Point = new Point();
			
			point.x = (mapWith / 2) + (long * (mapWith / 360));
			
			var latrad:Number = MathUtils.convertToRadian(lat);
			var my:Number = 1.25 * Math.log(Math.tan((Math.PI / 4) + (0.4 * latrad)));
			
			point.y = (mapHeight / 2) - (my * (mapHeight / 4.6));						
			
			return point;
		}
		
		public static function random(startValue:Number, endValue:Number, asInt:Boolean=false):Number
		{			
			var range:Number = Math.abs(startValue) + endValue;
			
			if (startValue < 0)
			{
				if (endValue < 0) range = Math.abs(startValue) + endValue;
				else range = Math.abs(startValue) + endValue;
			}
			else
			{
				if (endValue < 0) range = -(startValue - endValue); 
				else range = endValue - startValue;				
			}			
			
			var rdm:Number = 0;			
			if (asInt) rdm = Math.round(Math.random() * range);
			else rdm = Math.random() * range;			
			
			var value:Number = startValue + rdm;
			
			return value;
			
			if( asInt ) 
			{
				return Math.round(Math.random() * (endValue-startValue));
			}
			return Math.random() * (endValue-startValue);
			
		}	
		
		
	}

}
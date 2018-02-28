package awaybuilder.view.components.controls.primitives
{
	import flash.display.Graphics;
	
	import spark.primitives.Line;
	public class DashedLine extends Line
	{
		private var _dashes : Array = [3, 3];

		public function get dashes():Array
		{
			return _dashes;
		}

		public function set dashes(value:Array):void
		{
			_dashes = value;
			invalidateSize();
			invalidateDisplayList();
		}

		override protected function draw(g:Graphics):void
		{
			
			if( dashes && dashes.length>0 ) {
				
				var x1:Number = measuredX + drawX;
				var y1:Number = measuredY + drawY;
				var x2:Number = measuredX + drawX + width;
				var y2:Number = measuredY + drawY + height;    
				
				var angle : Number = Math.atan( (x2-x1) / (y2-y1) );
				var distance : Number = Math.sqrt( Math.pow( x2-x1, 2) + Math.pow(y2-y1, 2) );
				
				var dashsCounter : Number = 0;
				var sectionLength : Number = 0;
				
				for(; dashsCounter<dashes.length; dashsCounter++) 
				{
					sectionLength += dashes[dashsCounter];
				}
				
				var numPasse : Number = Math.abs(distance/(sectionLength));
				
				var startX : Number = 0;
				var startY : Number = 0;
				
				if ((xFrom <= xTo) == (yFrom <= yTo)) 
				{ 
					startX = x1,
					startY = y1;
				}
				else 
				{
					startX = x1,
					startY = y2;
				}
				
				var currentX : Number = startX;
				var currentY : Number = startY;
				
				g.moveTo( currentX, currentY );
				
				var currentDistance : Number = 0;
				var counter : Number = 0;
				
				dashsCounter = 0;
				
				for(; counter<numPasse; counter++) 
				{
					for(; dashsCounter<dashes.length; dashsCounter++) 
					{
						
						currentX += Math.abs(dashes[dashsCounter]*Math.sin(angle));
						currentY += Math.abs(dashes[dashsCounter]*Math.cos(angle));
						
						currentDistance = Math.sqrt( Math.pow(currentX-startX, 2) + Math.pow(currentY-startY, 2) );
						
						if( currentDistance > distance ) 
						{
							
							if ((xFrom <= xTo) == (yFrom <= yTo)) 
							{ 
								currentX = x2,
								currentY = y2;
							}
							else {
								currentX = x2,
								currentY = y1;
							}
						}
						
						if( dashsCounter%2 == 0 ) 
						{
							g.lineTo( currentX, currentY );
						}
						else 
						{
							g.moveTo( currentX, currentY );
						}
						
					}
					dashsCounter = 0;
				}
			}
		}
	}
}
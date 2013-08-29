package renderer
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.IDataRenderer;
	import mx.graphics.IStroke;
	import mx.skins.ProgrammaticSkin;

	/*
	*  作者：偶尔陶醉
	*  My blog：www.stutostu.com
	*  拥护互联网精神，你可以修改使用本源码，发布时请注明来源。
	* 大部分源码来自于adobe flex的源码
	*/
	public class MyLineRenderer extends ProgrammaticSkin implements IDataRenderer{
	
		public function MyLineRenderer() 
		{
			super();
		}
		private var _data:Object;
		[Inspectable(environment="none")]
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var stroke:IStroke = getStyle("lineStroke");		
			var form:String = getStyle("form");
			
			graphics.clear();

			this.drawline(graphics, _data.items,
				_data.start, _data.end + 1,"x","y",
				stroke,form);
		}
		
		private function  drawline(g:Graphics, pts:Array /* of Object */,
								   start:int, end:int,
								   hProp:String, vProp:String,
								   stroke:IStroke, form:Object,
								   moveToStart:Boolean = true):void
		{
			if (start == end)
				return;
			
			var originalStart:int = start;
			
			form = 5;
			
			if (stroke)
				stroke.apply(g,null,null);

			/*
			//设置线条样式
			var up:uint = 0xFF0000;//颜色
			var upThickness:int = 3;//线条粗细
			var down:uint = 0x008000;
			var downThickness:int = 2;
			*/

			
			var len:Number;
			var incr:int;
			var i:int;
			var w:Number;
			var c:Number;
			var a:Number;
			
			var reverse:Boolean = start > end;
			
			if (reverse)
				incr = -1;
			else
				incr = 1;
			
			if (moveToStart)
				g.moveTo(pts[start][hProp], pts[start][vProp]);
			else
				g.lineTo(pts[start][hProp], pts[start][vProp]);
			
			start += incr;
			
			start = originalStart;
			var innerEnd:int = end - incr;
			
			// Check for coincident points at the head of the list.
			// We'll skip over any of those			
			while (start != end)
			{
				if (pts[start + incr][hProp] != pts[start][hProp] ||
					pts[start + incr][vProp] != pts[start][vProp])
				{
					break;
				}
				start += incr;
			}
			if (start == end || start + incr == end)
				return;
			
			if (Math.abs(end - start) == 2)
			{
				g.lineTo(pts[start + incr][hProp], pts[start + incr][vProp]);
				return;
			}
			
			var tanLeft:Point = new Point();
			var tanRight:Point = new Point();
			var tangentLengthPercent:Number = 0.25;
			
			if (reverse)
				tangentLengthPercent *= -1;
			
			var j:int= start;
			
			// First, find the normalized vector
			// from the 0th point TO the 1st point
			var v1:Point = new Point();
			var v2:Point = new Point(pts[j + incr][hProp] - pts[j][hProp],
				pts[j + incr][vProp] - pts[j][vProp]);
			var tan:Point = new Point();
			var p1:Point = new Point();
			var p2:Point = new Point();
			var mp:Point = new Point();
			
			len = Math.sqrt(v2.x * v2.x + v2.y * v2.y);
			v2.x /= len;
			v2.y /= len;
			
			// Now later on we'll be using the tangent to the curve
			// to define the control point.
			// But since we're at the end, we don't have a tangent.
			// Instead, we'll just use the first segment itself as the tangent.
			// The effect will be that the first curve will start along the
			// polyline.
			// Now extend the tangent to get a control point.
			// The control point is expressed as a percentage
			// of the horizontal distance beteen the two points.
			var tanLenFactor:Number = pts[j + incr][hProp] - pts[j][hProp];
			
			var prevNonCoincidentPt:Object = pts[j];
			
			// Here's the basic idea.
			// On any given iteration of this loop, we're going to draw the
			// segment of the curve from the nth-1 sample to the nth sample.
			// To do that, we're going to compute the 'tangent' of the curve
			// at the two samples.
			// We'll use these two tangents to find two control points
			// between the two samples.
			// Each control point is W pixels along the tangent at the sample,
			// where W is some percentage of the horizontal distance
			// between the samples.
			// We then take the two control points, and find the midpoint
			// of the line between them.
			// Then we're ready to draw.
			// We draw two quadratic beziers, one from sample N-1
			// to the midpoint, with control point N-1, and one
			// from the midpoint to sample N, with the control point N.
			
			for (j += incr; j != innerEnd; j += incr)
			{
				// Check and see if the next point is coincident.
				// If it is, we'll skip forward.
				if (pts[j + incr][hProp] == pts[j][hProp] &&
					pts[j + incr][vProp] == pts[j][vProp])
				{
					continue;
				}

				/*
				//判断大小 决定线条样式
				if( pts[j].yNumber > pts[j - incr ].yNumber )
				{
					g.lineStyle( upThickness , up );
				}else{
					g.lineStyle( downThickness , down );
				}
				*/
				// v1 is the normalized vector from the nth point
				// to the nth-1 point.
				// Since we already computed from nth-1 to nth,
				// we can just invert it.
				v1.x = -v2.x
					v1.y = -v2.y;
				
				// Now compute the normalized vector from nth to nth+1. 
				v2.x = pts[j + incr][hProp] - pts[j][hProp];
				v2.y = pts[j + incr][vProp] - pts[j][vProp];
				
				len = Math.sqrt(v2.x * v2.x + v2.y * v2.y);
				v2.x /= len;
				v2.y /= len;
				
				// Now compute the 'tangent' of the C1 curve
				// formed by the two vectors.
				// Since they're normalized, that's easy to find...
				// It's the vector that runs between the two endpoints.
				// We normalize it, as well.
				tan.x = v2.x - v1.x;
				tan.y = v2.y - v1.y;
				var tanlen:Number = Math.sqrt(tan.x * tan.x + tan.y * tan.y);
				tan.x /= tanlen;
				tan.y /= tanlen;
				
				// Optionally, if the vertical direction of the curve
				// reverses itself, we'll pin the tangent to be  horizontal.
				// This works well for typical, well spaced chart lines,
				// not so well for arbitrary curves.
				if (v1.y * v2.y >= 0)
					tan = new Point(1, 0);
				
				// Find the scaled tangent we'll use
				// to calculate the control point.
				tanLeft.x = -tan.x * tanLenFactor * tangentLengthPercent;
				tanLeft.y = -tan.y * tanLenFactor * tangentLengthPercent;
				
				if (j == (incr+start))
				{
					// The first segment starts along the polyline,
					// so we only draw a single quadratic.
					//					g.moveTo(pts[j - incr].x, pts[j - incr].y);
					g.curveTo(pts[j][hProp] + tanLeft.x,
						pts[j][vProp] + tanLeft.y,
						pts[j][hProp],
						pts[j][vProp]);
				}
				else
				{
					// Determine the two control points...
					p1.x = prevNonCoincidentPt[hProp] + tanRight.x;
					p1.y = prevNonCoincidentPt[vProp] + tanRight.y;
					
					p2.x = pts[j][hProp] + tanLeft.x;
					p2.y = pts[j][vProp] + tanLeft.y;
					
					// and the midpoint of the line between them.
					mp.x = (p1.x+p2.x)/2
					mp.y = (p1.y+p2.y)/2;
					
					// Now draw our two quadratics.
					g.curveTo(p1.x, p1.y, mp.x, mp.y);
					g.curveTo(p2.x, p2.y, pts[j][hProp], pts[j][vProp]);
					
				}
				
				// We're about to move on to the nth to the nth+1 segment
				// of the curve...so let's flip the tangent at n,
				// and scale it for the horizontal distance from n to n+1.
				tanLenFactor = pts[j + incr][hProp] - pts[j][hProp];
				tanRight.x = tan.x * tanLenFactor * tangentLengthPercent;
				tanRight.y = tan.y * tanLenFactor * tangentLengthPercent;
				prevNonCoincidentPt = pts[j];
			}
			
			// Now in theory we're going to draw our last curve,
			// which, like the first, is only a single quadratic,
			// ending at the last sample.
			// If we try and draw two curves back to back, in reverse order,
			// they don't quite match.
			// I'm not sure whether this is expected, based on the definition
			// of a quadratic bezier, or a bug in the player.
			// Regardless, to work around this, we'll draw the last segment
			// backwards.
			//最后一段
			/*
			if(  pts[j].yNumber  > pts[j - incr ].yNumber  )
				g.lineStyle( upThickness , up );
			else
				g.lineStyle( downThickness , down );
			*/
//			if( isNaN( pts[j].yNumber )  )
//				g.lineStyle(0 , 0 , 0);
			
			g.curveTo(prevNonCoincidentPt[hProp] + tanRight.x,
				prevNonCoincidentPt[vProp] + tanRight.y,
				pts[j][hProp], pts[j][vProp]);
			
		}
		
	}

}
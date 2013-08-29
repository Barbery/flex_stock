package utils
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.charts.renderers.CandlestickItemRenderer;
	import mx.charts.series.items.HLOCSeriesItem;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	
	public class MyMSeriesRenderer_2 extends CandlestickItemRenderer
	{
		private var _width:Number;
		public function MyMSeriesRenderer_2()
		{
			super();
		}
		private var _chartItem:HLOCSeriesItem;
		[Inspectable(environment="none")]
		
		override public function get data():Object
		{
			return _chartItem;
		}
		
		override public function set data(value:Object):void
		{
			FlexGlobals.topLevelApplication.parameters.ii++;
			_chartItem=value as HLOCSeriesItem;
			this.alpha=1;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var stroke:IStroke = getStyle("stroke");
			var boxStroke:IStroke = getStyle("boxStroke");
			
			var fill:IFill;
			var w:Number = boxStroke ? boxStroke.weight / 2 : 0;
			var rc:Rectangle;
			var g:Graphics = graphics;
			var state:String;
			var stroke_color:int = 0;
			
//			_chartItem.low = Math.min(_chartItem.close , _chartItem.open);
//			_chartItem.high = Math.max(_chartItem.close , _chartItem.open);

			if (_chartItem)
			{
				fill = data.fill;
				var fill_color:uint = GraphicsUtilities.colorFromFill(fill);
				state = data.currentState;
				//1920x1080 width=3.46**** height=33.81****
				//1600x900  width=2.83**** height=27.14****
				//1280x720  width=2.28**** height=20.49****
				//1024x768  width=1.73**** height=22.38****
//				Alert.show("宽度"+unscaledWidth.toString());
//				Alert.show("高度"+unscaledHeight.toString());
				_width = unscaledWidth;
		
				var min:Number;
				var max:Number;

				
				if(_chartItem.high > _chartItem.low) // if axis is inverted
				{
					min = Math.max(_chartItem.high,Math.max(_chartItem.close,_chartItem.open));
					max = Math.min(_chartItem.low,Math.min(_chartItem.open,_chartItem.close));
				}
				else
				{
					max = Math.min(_chartItem.high,Math.min(_chartItem.close,_chartItem.open));
					min = Math.max(_chartItem.low,Math.max(_chartItem.open,_chartItem.close));
				}
				var boxMin:Number = Math.min(_chartItem.open, _chartItem.close);
				var boxMax:Number = Math.max(_chartItem.open, _chartItem.close);
				var candlestickHeight:Number = min- max;
				var heightScaleFactor:Number = height / candlestickHeight;
				//K线中的柱子
//				Alert.show(width.toString());
				rc = new Rectangle(w,(boxMin - max) * heightScaleFactor + w , _width,	(boxMax - boxMin) * heightScaleFactor - 2 * w);

				g.clear();		
				g.moveTo(rc.left,rc.top);

//---------------填充柱子------------------------------------				
				if (fill)
					fill.begin(g,rc,null);
				
				g.lineStyle(1,fill_color);
				g.lineTo(rc.right, rc.top);
				g.lineTo(rc.right, rc.bottom);
				g.lineTo(rc.left, rc.bottom);
				g.lineTo(rc.left, rc.top);
				if (fill)
					fill.end(g);
//--------------------------------------------------
				
				//绘制不上下隐藏部分矩形
				if (boxStroke && stroke)
				{
					g.beginFill(0xFF00FF , 0);
					g.drawRect( 0, 0 , _width , height);
					g.endFill();

				}
				
				
			}
			/*
			else
			{
				fill = GraphicsUtilities.fillFromStyle(getStyle("declineFill"));
				var declineFill:IFill = GraphicsUtilities.fillFromStyle(getStyle("fill"));
				
				rc = new Rectangle(0, 0, unscaledWidth, unscaledHeight);
				
				g.clear();		
				g.moveTo(width, 0);
				if (fill)
					fill.begin(g, rc,null);
				g.lineStyle(0, 0, 0);
				g.lineTo(0, height);			
				if (boxStroke)
					boxStroke.apply(g,null,null);
				g.lineTo(0, 0);
				g.lineTo(width, 0);
				if (fill)
					fill.end(g);
				if (declineFill)
					declineFill.begin(g, rc, null);
				g.lineTo(width, height);
				g.lineTo(0, height);
				g.lineStyle(0, 0, 0);
				g.lineTo(width, 0);			
				if (declineFill)
					declineFill.end(g);
			}*/
		}
		
	}
}
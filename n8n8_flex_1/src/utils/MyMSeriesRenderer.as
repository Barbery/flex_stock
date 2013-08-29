package utils
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.charts.renderers.CandlestickItemRenderer;
	import mx.charts.series.items.HLOCSeriesItem;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	
	public class MyMSeriesRenderer extends CandlestickItemRenderer
	{
		private var _width:Number;
		public function MyMSeriesRenderer()
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

			if (_chartItem)
			{
				fill = data.fill;
				state = data.currentState;
				//1920x1080 width=3.46**** height=33.81****
				//1600x900  width=2.83**** height=27.14****
				//1280x720  width=2.28**** height=20.49****
				//1024x768  width=1.73**** height=22.38****
//				Alert.show("宽度"+unscaledWidth.toString());
//				Alert.show("高度"+unscaledHeight.toString());
				_width = unscaledWidth * 4;
//				var color:uint;
/*				switch (state)
				{
					case ChartItem.FOCUSED:
					case ChartItem.ROLLOVER:
						if (styleManager.isValidStyleValue(getStyle('itemRollOverColor')))
							color = getStyle('itemRollOverColor');
						else
							color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),-20);
						fill = new SolidColor(color);
						break;
					case ChartItem.DISABLED:
						if (styleManager.isValidStyleValue(getStyle('itemDisabledColor')))
							color = getStyle('itemDisabledColor');
						else
							color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),20);
						fill = new SolidColor(GraphicsUtilities.colorFromFill(color));
						break;
					case ChartItem.FOCUSEDSELECTED:
					case ChartItem.SELECTED:
						if (styleManager.isValidStyleValue(getStyle('itemSelectionColor')))
							color = getStyle('itemSelectionColor');
						else
							color = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(fill),-30);
						fill = new SolidColor(color);
						break;
				}
*/			
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
				if (boxStroke && stroke) {
					if (_chartItem.close > _chartItem.open)
						boxStroke.apply(g,null,null);
					else
						stroke.apply(g,null,null);
				}
				else
					g.lineStyle(0,0,0);
				if (fill)
					fill.begin(g,rc,null);
				//定义矩形border的颜色
				if(_chartItem.close - _chartItem.open > 0)
					g.lineStyle(1,0x54FCFC);
				else if(_chartItem.close - _chartItem.open < 0)
					g.lineStyle(1,0xFF0000);
				else
					g.lineStyle(1,0xFFFFFF);
				g.lineTo(rc.right*2, rc.top);
				g.lineTo(rc.right*2, rc.bottom);
				g.lineTo(rc.left*2, rc.bottom);
				g.lineTo(rc.left*2, rc.top);
				if (fill)
					fill.end(g);
				if (boxStroke && stroke)
				{
					g.moveTo(_width , 0);
					g.lineTo(_width , (boxMin - max) * heightScaleFactor);
					g.moveTo(_width , (boxMax - max) * heightScaleFactor);
					g.lineTo(_width , height);
				}
			}
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
			}
		}
		
	}
}
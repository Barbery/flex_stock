package components
{
	/**
	 * 虚线类库
	 */
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.charts.GridLines;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.ChartState;
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.charts.chartClasses.IAxisRenderer;
	import mx.charts.styles.HaloDefaults;
	import mx.core.IFlexModuleFactory;
	import mx.core.mx_internal;
	import mx.graphics.IStroke;
	import mx.styles.CSSStyleDeclaration;
	
	import utils.GraphicsUtils;
	
	use namespace mx_internal;
	
	[Style(name="horizontalLineStyle", type="String", enumeration="solid,dash", inherit="no")]
	[Style(name="verticalLineStyle", type="String", enumeration="solid,dash", inherit="no")]
	[Style(name="horizontalLineGap", type="int", inherit="no")]
	[Style(name="verticalLineGap", type="int", inherit="no")]
	
	public class GridLinesEx extends GridLines
	{
		public function GridLinesEx()
		{
			super();
		}
		
		private var _moduleFactoryInitialized:Boolean = false;
		
		override public function set moduleFactory(factory:IFlexModuleFactory):void
		{
			super.moduleFactory = factory;
			
			if (_moduleFactoryInitialized)
				return;
			
			_moduleFactoryInitialized = true;
			
			// our style settings
			initStyles();
		}
		
		private function initStyles():Boolean
		{
			HaloDefaults.init(styleManager);
			
			var gridlinesStyleName:CSSStyleDeclaration =
				HaloDefaults.createSelector("components.GridLinesEx", styleManager);
			
			gridlinesStyleName.defaultFactory = function():void
			{
				this.horizontalLineStyle = "solid";
				this.verticalLineStyle = "solid";
				this.horizontalLineGap = 2;
				this.verticalLineGap = 2;
			}
			return true;
		}
		
		
		override protected function updateDisplayList(w:Number,
			h:Number):void
		{
			super.updateDisplayList(w, h);
			var len:int;
			var c:Object;
			var stroke:IStroke;
			var changeCount:int;
			var ticks:Array /* of Number */;
			var spacing:Array /* of Number */;
			var axisLength:Number;
			var colors:Array /* of IFill */;
			var rc:Rectangle;
			var originStroke:IStroke;
			var addedFirstLine:Boolean;
			var addedLastLine:Boolean;
			var n:int;
			
			if (!chart||
				chart.chartState == ChartState.PREPARING_TO_HIDE_DATA ||
				chart.chartState == ChartState.HIDING_DATA)
			{
				return;
			}
			
			var g:Graphics = graphics;
			g.clear();
			
			g.lineStyle(1, 0xFF0000, 1);
			var gridDirection:String = getStyle("gridDirection");
			var horizontalLineGap:int = getStyle("horizontalLineGap");
			
			if (gridDirection == "horizontal")
			{
				stroke = getStyle("horizontalStroke");
				
				changeCount = Math.max(1, getStyle("horizontalChangeCount"));
				if ((changeCount * 0 != 0) || changeCount <= 1)
					changeCount = 1;
				
				for each(var verticalAxisRenderer:IAxisRenderer in CartesianChart(chart).verticalAxisRenderers)
				{
					
					ticks = verticalAxisRenderer.ticks.concat();
				}
				
				if (getStyle("horizontalTickAligned") == false)
				{
					len = ticks.length;
					spacing = [];
					n = len;
					for (var i:int = 1; i < n; i++)
					{
						spacing[i - 1] = (ticks[i] + ticks[i - 1]) / 2;
					}
				}
				else
				{
					spacing = ticks;
				}
				
				addedFirstLine = false;
				addedLastLine = false;
				
				if (spacing[0] != 0)
				{
					addedFirstLine = true;
					spacing.unshift(0);
				}
				
				if (spacing[spacing.length - 1] != 1)
				{
					addedLastLine = true;
					spacing.push(1);
				}
				
				axisLength = unscaledHeight;
				
				colors = [ getStyle("horizontalFill"),
					getStyle("horizontalAlternateFill") ];
				
				len = spacing.length;
				
				if (spacing[len - 1] < 1)
				{
					c = colors[1];
					if (c != null)
					{
						//g.lineStyle(0, 0xFF0000, 0);
						var $y:Number = spacing[len - 1] * axisLength;
						GraphicsUtils.drawDashedLine(g, 0, $y, w, h, stroke, [horizontalLineGap]);
					}
				}
				
				n = spacing.length;
				for (i = 0; i < n; i += changeCount)
				{
					var idx:int = len - 1 - i;
					c = colors[(i / changeCount) % 2];
					var bottom:Number = spacing[idx] * axisLength;
					var top:Number =
						spacing[Math.max(0, idx - changeCount)] * axisLength;
					rc = new Rectangle(0, top, unscaledWidth, bottom-top);
					
					if (c != null)
					{
						//g.lineStyle(0, 0xFFFFFF, 0);
						GraphicsUtils.drawDashedLine(g, rc.left, rc.top,rc.right, rc.bottom, stroke, [horizontalLineGap]);
					}
					
					if (stroke && rc.bottom >= -1) //round off errors
					{
						if (addedFirstLine && idx == 0)
							continue;
						if (addedLastLine && idx == (spacing.length-1))
							continue;
						
						//stroke.apply(g,null,null);

						GraphicsUtils.drawDashedLine(g, rc.left, rc.bottom,rc.right, rc.bottom, stroke, [horizontalLineGap]);
						
					}
				}
			}
		}
		
	}
}
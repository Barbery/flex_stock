package preloader
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	
	import mx.graphics.codec.PNGEncoder;
	
	public class WelcomeScreen extends Loader
	{
		//辅助属性，帮助进行进度条的定位
		private static var _LogoWidth:int = 280;
		private static var _LogoHeight:int = 180;
		private static var _LeftMargin:int = 5;
		private static var _RightMargin:int = 5;
		private static var _TopMargin:int = 1;
		private static var _BottomMargin:int = 1;
		private static var _Padding:int = -60;
		//Progress bar settings
		//进度条的设定，比如显色边框等
		private static var _BarWidth:int = 220;
		private static var _BarHeight:int = 12;
		private static var _BarBackground:uint  = 0xFFFFFF;
		private static var _BarOuterBorder:uint = 0x737373;
		private static var _BarColor:uint = 0x6F9FD5;
		private static var _BarInnerColor:uint = 0xFFFFFF;
		
		public  var progress:Number;
		private var _logoData : BitmapData;
		
		public function WelcomeScreen()
		{
			//this.loadBytes(new WelcomeScreenGraphic() as ByteArray);
		}
		
		override public function get width() : Number
		{
			return Math.max(_BarWidth, _LogoWidth) + _LeftMargin + _RightMargin;
		}
		
		override public function get height() : Number
		{
			return _LogoHeight + _BarHeight + _Padding + _TopMargin + _BottomMargin;
		}
		
		/**
		 * 刷新函数，每个时钟周期都被调用的函数
		 */
		public function refresh():void
		{
			_logoData = this.drawProgressBar();
			var encoder:PNGEncoder = new PNGEncoder();
			this.loadBytes(encoder.encode(_logoData));
		}
		/**
		 * 进度条生成函数
		 */
		private function drawProgressBar():BitmapData
		{
			// create bitmap data to create the data
			var data : BitmapData = new BitmapData(this.width, this.height, true, 0);
			// draw the progress bar
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			// draw the bar background
			g.beginFill(_BarBackground);
			g.lineStyle(2, _BarOuterBorder, 1, true);
			var px : int = (this.width - _BarWidth) / 3;
			var py : int = _TopMargin + _LogoHeight + _Padding;
			g.drawRoundRect(px, py, _BarWidth, _BarHeight, 2);
			var containerWidth : Number = _BarWidth - 4;
			var progWidth:Number = containerWidth * this.progress / 100;
			g.beginFill(_BarColor);
			g.lineStyle(1, _BarInnerColor, 1, true);
			//根据progress进度，来画出进度条的长度
			g.drawRect(px + 1, py + 1, progWidth, _BarHeight - 3);
			data.draw(s);
			return data;
		}
		
	}
}
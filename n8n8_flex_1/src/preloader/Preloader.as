package preloader
{
	import components.MySocket;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	
	public class Preloader extends DownloadProgressBar
	{
		//显示进度的文字
		private var progressText:TextField;
		//logo页面
		public var logo:WelcomeLogo;
		private var _timer:Timer;
		private var _preloader:Sprite;
		private var socketReady:Boolean =false;
		private var loadReady:Boolean = false;
		private var _x:Number;
		private var _y:Number;
		private var i:int = 0;
		
		public function Preloader()
		{
			(new MySocket).testSpeed();
			testSocket();
			super();
			//加入logo
			logo = new WelcomeLogo();
			this.addChild(logo);
			
			//加入进度文字
			progressText = new TextField();
			progressText.x = 20;
			progressText.y = 80;
			progressText.width = 200;
			progressText.height = 22;
			progressText.textColor = 0xFFFFFF;
			progressText.autoSize = "left";
			progressText.wordWrap = true;
			this.addChild(progressText);

		}
		
		private function testSocket():void
		{
			var byte:ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			
			byte.writeUnsignedInt( 100 );
			byte.writeUnsignedInt( 1396982613 );
			byte.writeInt( 1701 );
			byte.writeUnsignedInt( 20 );
			byte.writeInt( 0 );
			byte.writeUnsignedInt( 0 );
			
			byte.writeInt( 0 );
			byte.writeInt( 1 );
			byte.writeInt( 0 );
			byte.writeInt( -1 );
			byte.writeInt( 4 );
			
			(new MySocket).send( byte , function(result:ByteArray):void{ socketReady = true; } );
		}
		
		/**
		 * override这个函数，来实现自己Preloader的设置，而不是用其默认的设置
		 */
		override public function set preloader(s:Sprite):void
		{
			_preloader = s;
			s.addEventListener(ProgressEvent.PROGRESS, progHandler);
			s.addEventListener(FlexEvent.INIT_COMPLETE , _initCompleteHandler);
			s.addEventListener( FlexEvent.INIT_PROGRESS , function():void{
				if(this.i++ % 3 === 0 )
					progressText.appendText('。');
			});
			s.addEventListener( Event.COMPLETE , function():void{
					//progressText.appendText('。');
			} );
		}
		
		private function progHandler(e:ProgressEvent):void
		{
			
			//在这里设置预载界面居中
			//如果在初始化函数中设置，会有stageWidth和最终界面大小不一致的错误，而导致不能居中
			centerPreloader();
			
			//计算进度，并且设置文字进度和进度条的进度。
			var prog:Number = e.bytesLoaded/e.bytesTotal*100;
			if( prog < 100)
			{
				progressText.text = "经传行情连接中，请耐心等候\n目前已下载： " + String(int(prog)) + "%";
			}
			else
			{
				progressText.text = '初始化行情连接中。';
			}


			if(this.i++ % 3 === 0 )
				progressText.appendText('。');
			
			var g:Graphics = this.graphics; //绘图区域
			g.clear();
			g.beginFill(0x88ff22);
			g.drawRect(0,120, 275, 20);
			g.endFill();
			g.beginFill(0xFF5500);
			g.drawRect(0,120, prog*2.75, 20);
			g.endFill();  

		}
		
		private function _initCompleteHandler(e:FlexEvent):void
		{
			progressText.appendText('。');
			testSocket();
			//如果载入完毕，则停止刷新
			loadReady = true;
			//测试专用。下载完毕后，不马上跳到程序的默认界面。而是停顿10秒后再跳入。
			_timer = new Timer(1000,15);
			_timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE , function():void{progressText.text = '行情连接失败，错误原因：行情连接超时！'});
			_timer.start();
		}

		/**
		 * 一定要分发这个事件，来通知程序已经完全下载，可以进入程序的默认界面了
		 */
		private function dispatchComplete(event:TimerEvent):void
		{
			progressText.appendText('。');
			if(  loadReady && socketReady )
			{
				_timer.stop();
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				testSocket();
			}
			
			if(this.i++ % 3 === 0 )
				progressText.appendText('。');
		}

		private function centerPreloader():void
		{
			if ((stage.stageWidth > 0) && (_preloader)) {
				_x = x = (stage.stageWidth / 2) - 150;
				_y = y = (stage.stageHeight / 2) - 90;
			}
		}
		
	}
}
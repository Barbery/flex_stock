package preloader
{
	import flash.display.Graphics;  
	import flash.display.Sprite;  
	import flash.events.*;  
	import flash.text.TextField;  
	import mx.containers.Canvas;  
	import mx.events.*;  
	import mx.preloaders.DownloadProgressBar;  
	public class MyDownProBar extends DownloadProgressBar  
	{  
		private var progressBar:Sprite;  
		private var myLabel:TextField  
		public function MyDownProBar(){  
			super();  
			myLabel=new TextField(); //创建显示信息的文本标签  
			myLabel.x=200;  
			myLabel.y=200;  
			myLabel.textColor = 0xFFFFFF;
			addChild(myLabel);  
		}  
		//覆盖DownloadProgressBar方法，监听相关事件  
		override public function set preloader(s:Sprite):void{  
			s.addEventListener(ProgressEvent.PROGRESS,inProgress);  
			s.addEventListener(Event.COMPLETE,complete);  
			s.addEventListener(FlexEvent.INIT_COMPLETE,initComplete);  
			s.addEventListener(FlexEvent.INIT_PROGRESS,initProgress);  
		}  
		//进程中自行绘图  
		private function inProgress(e:ProgressEvent):  void {
			var barWidth:Number = e.bytesLoaded/e.bytesTotal*100;  
			var g:Graphics = this.graphics; //绘图区域  
			g.clear();  
			g.beginFill(0x88ff22);  
			g.drawRect(180,220, 100, 20);  
			g.endFill();  
			g.beginFill(0xff9900);  
			g.drawRect(180,220, barWidth, 20);  
			g.endFill();  
			myLabel.text=String(int(barWidth))+ " %";  
		}  
		private function complete(e:Event):void{  
			myLabel.text="下载完毕";  
		}  
		private function initComplete(e:FlexEvent):void{  
			myLabel.text="初始化完毕" 
			//初始完后要派发 Complete 事件，不然不会进入第二帧  
			dispatchEvent(new Event(Event.COMPLETE));  
		}  
		private function initProgress(e:FlexEvent):void{  
			myLabel.text="初始化..."; //进度条开始加载的方法  
		}  
	} 
}
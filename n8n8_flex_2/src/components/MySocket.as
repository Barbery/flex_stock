package components
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	/**
	 * 
	 * @author Barbery
	 * 
	 * 所有socket请求均走这个文件
	 * 
	 */	
	
	public class MySocket
	{
		private var _CurSocket:Socket = new Socket();
		private var _callBack:Function;
		private var _isReadHead:Boolean = false;
		private var _length:uint;
		private var _timer:Timer;
		private static var _ip:String;
		private static var _port:int;
		
		public function MySocket()
		{
			_CurSocket.addEventListener(ProgressEvent.SOCKET_DATA , socketHandler);
			if( _port < 1 )
			{
				testSpeed();
			}

		}
		
		/**
		 *
		 * 获取最快的ip地址
		 *  
		 */
		public function testSpeed():void
		{
			var ip1 = "**.**.**.**";
			var ip2 = "**.**.**.**";
			//连接ip
			if ( Math.random() > 0.6 )
			{
				var _socket1:Socket = new Socket();
				_socket1.connect( ip1, 60000);
			}
			else
			{
				var _socket2:Socket = new Socket();
				_socket2.connect( ip2, 60000);
			}
			
			var i:int = 0;
			//50毫秒重连一次，50*300=15s超时
			_timer = new Timer( 50 , 300 );
			_timer.addEventListener(TimerEvent.TIMER , 
				function():void
				{
					
					if( _socket2 !==null && _socket2.connected )
					{
						_ip = ip2;
						_port = 60000;
						_timer.stop();
					}
					
					if( _socket1 !== null && _socket1.connected )
					{
						_ip = ip1;
						_port = 60000;
						_timer.stop();
					}
					
					//每5s 超时，自动切换到另外一台服务器
					if( ++i % 40 === 0 )
					{
						if( _socket1 !==null )
						{
							_ip = ip2;
							_port = 60000;
							_timer.stop();
						}
						
						if( _socket2 !== null )
						{
							_ip = ip1;
							_port = 60000;
							_timer.stop();
						}
					}
					
					
				});
			_timer.start();

		}
		
		/**
		 * 发送数据请求
		 * @param byte 包头
		 * @param Back 回调函数
		 * 
		 */
		
		public function send( byte:ByteArray , Back:Function ):void
		{
			if( ! _CurSocket.connected )
			{
				_CurSocket.connect(_ip , _port );
				_timer = new Timer( 9000 , 1 );
				_timer.addEventListener(TimerEvent.TIMER , 
					function():void
					{
						_CurSocket.close();
					},
					false , 0 , true);
				_timer.start();
				
			}
			
			_callBack = Back;
			_CurSocket.writeBytes( byte );
			_CurSocket.flush();
		}
		
		private function socketHandler(event:ProgressEvent):void
		{
			if( ! this._isReadHead && _CurSocket.bytesAvailable >= 24 )
			{
				
				var head:ByteArray = new ByteArray();
				_CurSocket.readBytes( head , 0 , 24 );
				
				head.endian = Endian.LITTLE_ENDIAN;
				head.position = 4;
				
				if (  head.readUnsignedInt() !==  1396982613 )
					return;
				
				head.position = 12;
				_length = head.readUnsignedInt();
				
				this._isReadHead = true;
			}
						
			if( this._isReadHead && _CurSocket.bytesAvailable === _length )
			{

				var result:ByteArray = new ByteArray();
				_CurSocket.readBytes( result , 0 );
				result.endian = Endian.LITTLE_ENDIAN;
				_callBack(result);
				this._isReadHead = false;
				_timer.stop();
				_CurSocket.close();
			}

		}
		
	}
}
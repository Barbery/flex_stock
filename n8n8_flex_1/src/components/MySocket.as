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
			_ip = "**.**.**.**";
			_port = 60000;
		}
		
		public function testSpeed():void
		{
			
			if ( Math.random() > 0.6 )
			{
				var _socket1:Socket = new Socket();
				_socket1.connect("**.**.**.**" , 60000);
			}
			else
			{
				var _socket2:Socket = new Socket();
				_socket2.connect("**.**.**.**" , 60000);
			}
			
			var i:int = 0;
			_timer = new Timer( 50 , 300 );
			_timer.addEventListener(TimerEvent.TIMER , 
				function():void
				{
					
					if( _socket2 !==null && _socket2.connected )
					{
						_ip = "**.**.**.**";
						_port = 60000;
						_timer.stop();
					}
					
					if( _socket1 !== null && _socket1.connected )
					{
						_ip = "**.**.**.**";
						_port = 60000;
						_timer.stop();
					}
					
					//每5s 超时，自动切换到另外一台服务器
					if( ++i % 40 === 0 )
					{
						if( _socket1 !==null )
						{
							_ip = "**.**.**.**";
							_port = 60000;
							_timer.stop();
						}
						
						if( _socket2 !== null )
						{
							_ip = "**.**.**.**";
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
//				_CurSocket.connect( "192.168.1.23" , 7709 );
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
			//Alert.show("发送了");
		}
		
		private function socketHandler(event:ProgressEvent):void
		{
			//Alert.show("接收到了");
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
			
			//Alert.show( _length.toString() + " == " + _CurSocket.bytesAvailable );
			
			if( this._isReadHead && _CurSocket.bytesAvailable === _length )
			{
				//Alert.show("接受到了" + _length);
//				if( _CurSocket.bytesAvailable > 500 )
//					Alert.show(_ip + ' | ' + _port);
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
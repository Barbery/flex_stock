package preloader
{
	import flash.display.Loader;
	import flash.utils.ByteArray;
	
	public class WelcomeLogo extends Loader
	{
		[Embed(source="../../img/logo.png", mimeType="application/octet-stream")]
		public var WelcomeScreenGraphic:Class;
		public function WelcomeLogo()
		{
			this.loadBytes(new WelcomeScreenGraphic() as ByteArray);
		}
		
	}
}
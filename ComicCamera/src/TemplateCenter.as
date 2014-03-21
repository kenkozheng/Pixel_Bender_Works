package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;

	/**
	 * 管理模版资源
	 * @author kenkozheng
	 */
	public class TemplateCenter
	{
		public static const TEMPLATES:Array = ["white","beam","geisyun","xmas01","1","2","daga2","dodon2","doujou","enkai","ituyaruka"];
		public static const TEMPLATE_WIDTH:int = 120;
		
		public static function get thumbnails():Vector.<Loader>
		{
			var thumbnails:Vector.<Loader> = new Vector.<Loader>();
			for (var i:int = 0; i < TEMPLATES.length; i++) 
			{
				var loader:Loader = new Loader();
				loader.name = TEMPLATES[i];
				loader.load(new URLRequest("app:/asset/thumbnail/icon_" + TEMPLATES[i] + ".jpg"));
				thumbnails.push(loader);
			}
			return thumbnails;
		}
		
		/**
		 * @param templateName
		 * @param callback 接收bitmap
		 */
		public static function loadBackground(templateName:String, callback:Function):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				callback(loader.content);
			});
			loader.load(new URLRequest("app:/asset/background/bg_" + templateName + ".jpg"));
		}
		
		/**
		 * @param templateName
		 * @param callback 接收bitmap
		 */
		public static function loadMask(templateName:String, callback:Function):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				callback(loader.content);
			});
			loader.load(new URLRequest("app:/asset/mask/sf_" + templateName + ".png"));
		}
	}
}
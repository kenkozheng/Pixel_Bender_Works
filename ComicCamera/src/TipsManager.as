package
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * 
	 * @author kenkozheng
	 */
	public class TipsManager
	{
		public static const SUCCESS:int = 0;
		public static const FAIL:int = 1;
		public static const WARNING:int = 2;
		
		public static var stage:Stage;
		private static var _timer:int;
		private static var _tipDialog:MovieClip;
		
		public static function showTip(type:int, message:String, miliSeconds:int = 2000):void
		{
			if(!stage)
				throw new Error("must set the stage attribute first!");
			
			if(_timer > 0)
				clearTimeout(_timer);
			if(_tipDialog)
			{
				stage.removeChild(_tipDialog);
			}
			if(type == SUCCESS)
				_tipDialog = new SuccessTipDialog();
			else if(type == FAIL)
				_tipDialog = new FailTipDialog();
			else
				_tipDialog = new WarningTipDialog();
			_tipDialog.txt.text = message;
			_tipDialog.bg.width = _tipDialog.txt.x + _tipDialog.txt.textWidth + 25;
			_tipDialog.txt.width = _tipDialog.txt.textWidth + 15;
			stage.addChild(_tipDialog);
			_tipDialog.x = (stage.stageWidth - _tipDialog.width)/2;
			_tipDialog.y = (stage.stageHeight - _tipDialog.height)/2;
			_timer = setTimeout(function():void
			{
				stage.removeChild(_tipDialog);
				_tipDialog = null;
				_timer = -1;
			}, miliSeconds);
		}
		
	}
}
package
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraUI;
	import flash.media.MediaType;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	/**
	 * 漫画相机
	 * @author kenkozheng
	 */
	public class ComicCamera extends Sprite
	{
		private var _camera:CameraUI;
		private var _resultImage:Bitmap;
		private var _originImage:Bitmap;
		private var _background:Bitmap;
		private var _comicMask:Bitmap;
		private var _controlPanel:ControlPanel;
		
		private var _lastThumbnailPanelX:Number;
		private var _templateUsing:String;
		
		public function ComicCamera()
		{
			super();

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.autoOrients = false;
			stage.displayState = StageDisplayState.FULL_SCREEN;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, exit);
		}
		
		protected function exit(event:KeyboardEvent):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onResized);
			takePhoto();
			
			_controlPanel = new ControlPanel();
			addChild(_controlPanel);
			_controlPanel.reTakeButton.addEventListener(MouseEvent.CLICK, takePhoto);
			_controlPanel.saveButton.addEventListener(MouseEvent.CLICK, savePhoto);
			_controlPanel.originButton.addEventListener(MouseEvent.CLICK, showOriginPhoto);
			_controlPanel.comicButton.addEventListener(MouseEvent.CLICK, showComicPhoto);
			_controlPanel.comicButton.visible = false;
			
			var thumbnails:Vector.<Loader> = TemplateCenter.thumbnails;
			for (var i:int = 0; i < thumbnails.length; i++) 
			{
				_controlPanel.thumbnailPanel.addChild(thumbnails[i]);
				thumbnails[i].x = (TemplateCenter.TEMPLATE_WIDTH + 5)*i;
				thumbnails[i].addEventListener(TouchEvent.TOUCH_TAP, useTemplate);
			}
			_controlPanel.thumbnailPanel.graphics.beginFill(0,0);		//热区
			_controlPanel.thumbnailPanel.graphics.drawRect(0, 0, _controlPanel.thumbnailPanel.width, _controlPanel.thumbnailPanel.height);
			_controlPanel.thumbnailPanel.graphics.endFill();
			
			_controlPanel.thumbnailPanel.addEventListener(TouchEvent.TOUCH_BEGIN, thumbnailListOnTouchBegin);
			_controlPanel.thumbnailPanel.addEventListener(TouchEvent.TOUCH_END, thumbnailListOnTouchEnd);
			
			onResized();
		}
		
		private function onResized(event:Event = null):void
		{
			if(stage.stageWidth > stage.stageHeight)
			{
				//奇葩的是，无论手机什么方向，xy都是一样的，x是短边，y是长边。因为过程中方向在变化
				_controlPanel.y = stage.stageWidth - _controlPanel.height - 10;
			}
			else
			{
				_controlPanel.y = stage.stageHeight - _controlPanel.height - 10;
			}
		}
		
		protected function thumbnailListOnTouchBegin(event:TouchEvent):void
		{
			_lastThumbnailPanelX = _controlPanel.thumbnailPanel.x;
			//94,11是初始位置
			_controlPanel.thumbnailPanel.startTouchDrag(event.touchPointID, false, new Rectangle(
				94 - _controlPanel.thumbnailPanel.width + TemplateCenter.TEMPLATE_WIDTH*3, 
				11, 
				_controlPanel.thumbnailPanel.width - TemplateCenter.TEMPLATE_WIDTH*3,
				1));
		}
		
		protected function thumbnailListOnTouchEnd(event:TouchEvent):void
		{
			_controlPanel.thumbnailPanel.stopTouchDrag(event.touchPointID);
		}
		
		protected function takePhoto(e:MouseEvent = null):void
		{
			if (CameraUI.isSupported)
			{
				_camera = new CameraUI();
				_camera.addEventListener(MediaEvent.COMPLETE, onComplete);
				_camera.addEventListener(ErrorEvent.ERROR, onError);
				_camera.launch(MediaType.IMAGE);
			}
		}
		
		protected function useTemplate(event:TouchEvent):void
		{
			showComicPhoto();
			
			//解决拖动和点击的冲突
			if(Math.abs(_controlPanel.thumbnailPanel.x - _lastThumbnailPanelX) > 3)
				return;
			if(_resultImage == null)
				return;
			
			var templateName:String = event.currentTarget.name;
			if(templateName == _templateUsing)
				return;
			
			_templateUsing = templateName;
			if(_background)
			{
				removeChild(_background);
				_background = null;
			}
			if(_comicMask)
			{
				removeChild(_comicMask);
				_comicMask = null;
			}
			if(templateName != "white")
			{
				TemplateCenter.loadBackground(templateName, function(bitmap:Bitmap):void
				{
					_background = bitmap;
					addChildAt(bitmap, 0);
					bitmap.width = _resultImage.width;
					bitmap.height = _resultImage.height;
				});
				TemplateCenter.loadMask(templateName, function(bitmap:Bitmap):void
				{
					_comicMask = bitmap;
					addChild(bitmap);
					bitmap.width = _resultImage.width;
					bitmap.height = _resultImage.height;
				});
			}
		}
		
		protected function savePhoto(event:MouseEvent):void
		{
			var bitmapData:BitmapData = new BitmapData(_resultImage.width/_resultImage.scaleX, _resultImage.height/_resultImage.scaleY);
			bitmapData.draw(this, new Matrix(1/_resultImage.scaleX, 0, 0, 1/_resultImage.scaleY), null, null, null, true);
			var cameraRoll:CameraRoll = new CameraRoll();
			TipsManager.stage = stage;
			cameraRoll.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				TipsManager.showTip(TipsManager.SUCCESS, "保存成功");
			});
			cameraRoll.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent):void
			{
				TipsManager.showTip(TipsManager.FAIL, "保存失败");	
			});
			cameraRoll.addBitmapData(bitmapData);
		}
		
		protected function showOriginPhoto(event:MouseEvent):void
		{
			if(_originImage)
				_originImage.visible = true;
			if(_resultImage)
				_resultImage.visible = false;
			_controlPanel.originButton.visible = false;
			_controlPanel.comicButton.visible = true;
		}
		
		protected function showComicPhoto(event:MouseEvent = null):void
		{
			if(_originImage)
				_originImage.visible = false;
			if(_resultImage)
				_resultImage.visible = true;
			_controlPanel.originButton.visible = true;
			_controlPanel.comicButton.visible = false;
		}
		
		protected function onComplete(event:MediaEvent):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loader.loadFilePromise(event.data);
			if(_resultImage)
			{
				removeChild(_resultImage);
				_resultImage = null;
			}
			if(_originImage)
			{
				removeChild(_originImage);
				_originImage = null;
			}
		}
		
		protected function imageLoaded(event:Event):void
		{
			showComicPhoto();
			
			var bitmapData:BitmapData = compress(event.target.content, 1000, 1000);
			if((stage.stageWidth < stage.stageHeight && bitmapData.width > bitmapData.height)
				|| (stage.stageWidth > stage.stageHeight && bitmapData.width < bitmapData.height))
			{
				trace("rotate bitmap");
				bitmapData = BitmapDataRotateHelper.rotateLeft(bitmapData);
			}
			var originBitmapData:BitmapData = bitmapData;
			bitmapData = new ComicFilter().start(bitmapData);
			
			_resultImage = new Bitmap(bitmapData);
			if(_background)
				addChildAt(_resultImage, 1);
			else
				addChildAt(_resultImage, 0);
			_resultImage.smoothing = true;
			_resultImage.scaleX = _resultImage.scaleY = Math.min(stage.stageWidth/_resultImage.width, stage.stageHeight/_resultImage.height);
			
			_originImage = new Bitmap(originBitmapData);
			if(_background)
				addChildAt(_originImage, 1);
			else
				addChildAt(_originImage, 0);
			_originImage.smoothing = true;
			_originImage.scaleX = _originImage.scaleY = Math.min(stage.stageWidth/_originImage.width, stage.stageHeight/_originImage.height);
			_originImage.visible = false;
		}
		
		
		protected function onError(event:ErrorEvent):void
		{
		}
		
		private function compress(bitmap:Bitmap, maxWidth:int, maxHeight:int):BitmapData
		{
			if(bitmap.width > maxWidth || bitmap.height > maxHeight)
			{
				var scale:Number = Math.min(maxWidth/bitmap.width, maxHeight/bitmap.height);
				var bitmapData:BitmapData = new BitmapData(bitmap.width*scale, bitmap.height*scale);
				bitmapData.draw(bitmap.bitmapData, new Matrix(scale,0,0,scale), null, null, null, true);
				bitmap.bitmapData.dispose();
				return bitmapData;
			}
			else
			{
				return bitmap.bitmapData;
			}
		}
		
	}
}




package
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	/**
	 * 
	 * @author kenkozheng
	 */
	public class BitmapDataRotateHelper
	{
		public function BitmapDataRotateHelper()
		{
		}
		
		public static function rotateLeft(origin:BitmapData):BitmapData
		{
			//转置bitmapdata
			var m:Matrix = new Matrix();
			m.rotate(Math.PI / 2);
			m.translate(origin.height, 0);
			var bd:BitmapData = new BitmapData(origin.height, origin.width);
			bd.draw(origin, m);
			return bd;
		}

		public static function rotateRight(origin:BitmapData):BitmapData
		{
			//转置bitmapdata
			var m:Matrix = new Matrix();
			m.rotate(-Math.PI / 2);
			m.translate(0, origin.width);
			var bd:BitmapData = new BitmapData(origin.height, origin.width);
			bd.draw(origin, m);
			return bd;
		}
	}
}
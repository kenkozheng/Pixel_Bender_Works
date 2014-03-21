package
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;

	/**
	 * 
	 * @author kenkozheng
	 */
	public class ComicFilter
	{
		[Embed(source = "asset/pbj/ComicCamera.pbj", mimeType = "application/octet-stream")]
		public var ComicPBJ:Class;
		[Embed(source = "asset/pbj/GrayScale.pbj", mimeType = "application/octet-stream")]
		public var GrayScalePBJ:Class;
		[Embed(source = "asset/background/slash.jpg")]
		public var SlashPNG:Class;
		
		public function ComicFilter()
		{
		}
		
		public function start(bitmapData:BitmapData):BitmapData
		{
			//获取灰度图
			var shader:Shader = new Shader(new GrayScalePBJ());
			shader.data.src.input = bitmapData;
			var result:Vector.<Number> = new Vector.<Number>();
			var shaderJob:ShaderJob = new ShaderJob(shader, result, bitmapData.width, bitmapData.height);
			shaderJob.start(true);
			
			//计算亮度分布
			var sum:Number = 0;
			for (var i:int = 0; i < result.length; i+=4) 
			{
				sum += result[i];
			}
			var average:Number = sum/bitmapData.width/bitmapData.height;
			
			//最终效果
			var standardAverage:Number = 0.7;	//参考标准
			shader = new Shader(new ComicPBJ());
			shader.data.slash.input = new SlashPNG().bitmapData;
			shader.data.src.input = bitmapData;
			shader.data.edgeThreshold.value = [0.1];
			shader.data.blankThreshold.value = [0.9 + (average-standardAverage)*0.1];
			shader.data.whiteThreshold.value = [0.6 + (average-standardAverage)*0.4];
			shader.data.slashThreshold.value = [0.4 + (average-standardAverage)*0.4];
			var resultBitmapData:BitmapData = new BitmapData(bitmapData.width, bitmapData.height);
			shaderJob = new ShaderJob(shader, resultBitmapData, bitmapData.width, bitmapData.height);
			shaderJob.start(true);
			return resultBitmapData;
		}
	}
}
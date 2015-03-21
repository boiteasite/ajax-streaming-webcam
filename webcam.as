/* Ajax Streaming Webcam */
/* V 1.1 */
/* Webcam library for streaming in JPG to a server */
/* Copyright (c) 2014 Jacques Malgrange <jacques.malgrange@gmail.com> */
/* http://www.boiteasite.fr/fiches/javascript_webcam_streaming.html */
/* Licensed under the MIT License */
/* http://opensource.org/licenses/MIT */

package {

	import flash.net.URLRequest;
	//import flash.system.SecurityPanel;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	
	import flash.system.Security;
	import flash.external.ExternalInterface;
	import flash.display.BitmapData;
	import com.adobe.images.JPGEncoder;
	import Base64;

	public class webcam extends Sprite {
		private var camera:Camera = null;
		private var buffer:BitmapData = null;
		private var interval:Number = 0;
		private var stream:String = null;
		private var video:Video = null;

		private var settings:Object = {
			bandwidth : 0,
			quality : 90,
			jpgEncode : 0, // 0 or 1
			jpgQuality : 60, // if encode JPG [0 - 100]
			framerate : 14,
			smoothing : false,
			deblocking : 0,
			wrapper : 'webcam',
			width : 320,
			height : 240,
			refresh : 700
		}

		public function webcam():void {
			flash.system.Security.allowDomain("*");
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.BEST;
			stage.align = StageAlign.TOP_LEFT; // centre
			settings = merge(settings, this.loaderInfo.parameters);
			var id:Number = -1;
			for (var i:Number= 0, l:Number = Camera.names.length; i < l; i++) {
				if (Camera.names[i] == "USB Video Class Video") {
					id = i;
					break;
				}
			}
			camera = Camera.getCamera();
			if (camera!=null) {
				if(ExternalInterface.available){
					loadCamera();
					ExternalInterface.addCallback("capture", capture);
					ExternalInterface.addCallback("turnOff", turnOff);
				}
			}
		}
		private function loadCamera(name:String = '0'):void {
			camera = Camera.getCamera(name);
			camera.addEventListener(StatusEvent.STATUS, cameraStatusListener);
			camera.setMode(settings.width, settings.height, settings.framerate);
			camera.setQuality(settings.bandwidth, settings.quality);
			video = new Video(stage.stageWidth, stage.stageHeight);
			video.smoothing = settings.smoothing;
			video.deblocking = settings.deblocking;
			video.attachCamera(camera);
			stage.addChild(video);
			video.x = (stage.stageWidth - video.width) / 2;
			video.y = (stage.stageHeight - video.height) / 2;
		}
		private function cameraStatusListener(evt:StatusEvent):void {if(!camera.muted) ExternalInterface.call('camOk');}
		public function turnOff():Boolean {video.attachCamera(null); stage.removeChild(video); return true;}
		public function capture(time:Number):Boolean {
			if (camera!=null) {
				if (buffer!=null) {return false;}
				buffer = new BitmapData(settings.width, settings.height);
				var stream:Timer = new Timer(settings.refresh);
				stream.addEventListener(TimerEvent.TIMER, streaming);
				stream.start();
				return true;
			}
			return false;
		}
		private function streaming(e:TimerEvent):void {
			buffer.draw(video);
			if(settings.jpgEncode==0) {
				for (var i:Number = 0; i<settings.height; ++i) {
					var row:String = "";
					for (var j:Number=0; j<settings.width; ++j) {
						row+= buffer.getPixel(j, i);
						row+= ";";
					}
					ExternalInterface.call(settings.wrapper+'.onSave', row);
				}
			} else {
				var jpg:ByteArray = new JPGEncoder(settings.jpgQuality).encode(buffer);
				var jpg64:String = 'data:image/jpeg;base64,' + Base64.encodeByteArray(jpg);
				ExternalInterface.call(settings.wrapper+'.onSave', jpg64);
			}

		}
		public static function merge(base:Object, overwrite:Object):Object {
			for(var key:String in overwrite) 
			if(overwrite.hasOwnProperty(key)){
				if(!isNaN(overwrite[key])) base[key] = parseInt(overwrite[key]);
				else if(overwrite[key]==='true') base[key] = true;
				else if(overwrite[key]==='false') base[key] = false;
				else base[key] = overwrite[key];
			}
			return base;
		}
	}
}

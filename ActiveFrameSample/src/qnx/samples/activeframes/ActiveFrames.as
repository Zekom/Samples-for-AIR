package qnx.samples.activeframes
{
	import qnx.display.IowWindow;
	import qnx.events.QNXCoverEvent;
	import qnx.events.QNXSystemEvent;
	import qnx.fuse.ui.text.Label;
	import qnx.fuse.ui.text.TextAlign;
	import qnx.fuse.ui.text.TextFormat;
	import qnx.system.QNXCover;
	import qnx.system.QNXCoverTransition;
	import qnx.system.QNXSystem;
	import qnx.system.QNXSystemPowerMode;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	public class ActiveFrames extends Sprite
	{
		private var label:Label;
		private var timer:Timer;
		private var __alarmID:int;
		private var cover:NativeWindow;
		
		private var coverlabel:Label;
		private var coverbg:Bitmap;
		
		public function ActiveFrames()
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//Create a label to show the time when the app is maximized.
			label = new Label();
			var format:TextFormat = label.format;
			format.size = 100;
			format.align = TextAlign.CENTER;
			label.format = format;
			label.width = stage.stageWidth;
			label.height = 300;
			addChild( label );
			
			//update the time every second.
			timer = new Timer( 1000 );
			timer.addEventListener(TimerEvent.TIMER, onTimer );
			timer.start();
			
			//Setup some listeners for the covers.
			QNXCover.qnxCover.transition = QNXCoverTransition.NONE;
			QNXCover.qnxCover.addEventListener(QNXCoverEvent.COVER_ENTER, onCoverEnter );
			QNXCover.qnxCover.addEventListener(QNXCoverEvent.COVER_EXIT, onCoverExit );
			QNXCover.qnxCover.addEventListener(QNXCoverEvent.COVER_SIZE, onCoverSize );
			
			//Create an event listener for the alarm when minimzed.
			QNXSystem.system.addEventListener(QNXSystemEvent.ALARM, onAlarm );
			
		}
		
		private function createCover():void
		{
			//Created a cover if we haven't already.
			if( cover == null )
			{
				var windowOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
				windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				windowOptions.type = NativeWindowType.LIGHTWEIGHT;
				
				cover = new NativeWindow(windowOptions);
				//It is important that these next 3 lines come directly after creating the window.
				var iow:IowWindow = IowWindow.getAirWindow(cover);
				iow.group = null;
				iow.numBuffers = 1;
				
				cover.stage.scaleMode = StageScaleMode.NO_SCALE;
				cover.stage.align = StageAlign.TOP_LEFT;
				cover.visible = false;
				coverbg = new Bitmap( new BitmapData( cover.width, cover.height, false, 0xFFFF0000 ) );
				cover.stage.addChild( coverbg );
				coverlabel = new Label();
				var format:TextFormat = coverlabel.format;
				format.color = 0xFAFAFA;
				format.size = 50;
				coverlabel.format = format;
				cover.stage.addChild( coverlabel );
			
				cover.activate();
			}
			
			//resize the cover.
			cover.width = QNXCover.qnxCover.coverWidth;
			cover.height = QNXCover.qnxCover.coverHeight;
			coverlabel.height = cover.height;
			coverlabel.width = cover.width;
			coverbg.height = cover.height;
			coverbg.width = cover.width;
			
		}
		
		
		private function onAlarm( event:QNXSystemEvent ):void
		{
			//When minimized the alarm will be fired on an interval.
			//We set the power mode to normal so the cover can render.
			//And we set it back to the original value after the render.
			var currentMode:String = QNXSystem.system.powerMode;
			QNXSystem.system.powerMode = QNXSystemPowerMode.NORMAL;
			
			coverlabel.text = parseTime();
			QNXSystem.system.powerMode = currentMode;
		}
		
		//Creates and resizes the cover.
		private function onCoverSize( event:QNXCoverEvent ):void
		{
			createCover();
			QNXCover.qnxCover.setCoverFromWindow( cover );
			
		}
		
		//Stops the alarm when the cover is no longer visible.
		private function onCoverExit( event:QNXCoverEvent ):void
		{
			QNXSystem.system.cancelAlarm(__alarmID);
		}

		//Start the alarm when the cover is shown.
		private function onCoverEnter( event:QNXCoverEvent ):void
		{
			coverlabel.text = parseTime();
			//Randomly picked 20 seconds to demo.
			//Updating covers frequently may cause some renders to be skipped.
			__alarmID = QNXSystem.system.setAlarm( 20 * 1000, true );
		}

		//Update the time.
		private function onTimer( event:TimerEvent ):void
		{
			var time:String = parseTime();
			label.text = time;
			coverlabel.text = time;
		}
		
		//Parse the time.
		private function parseTime():String
		{
			var now:Date = new Date();
			var mins:int = now.getMinutes();
			var secs:int = now.getSeconds();
			var str:String = now.getHours() + ":" + ((mins < 10 ) ? "0"+mins:mins) + ":" + ((secs < 10 ) ? "0"+secs:secs);
			return( str );
		}
		
		
	}
}

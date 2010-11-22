package com.pomodairo
{
	import com.pomodairo.components.config.SoundConfigPanel;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.core.SoundAsset;
	import mx.effects.SoundEffect;
	import mx.effects.easing.Linear;

	public class SoundPlayer
	{
		[Embed(source="alarm.mp3")]
		public var alarmClass:Class;
		
		[Embed(source="ticking.mp3")]
		public var tickClass:Class;
		
		private var soundEnabled:Boolean = true;
		
		private var fadeSound:Boolean = true;
		
		private var ticToc:SoundChannel;
		
		private var alarmSound:String = "";
		
		private var clockSound:String = "";
		
		private var alarmSoundChannel:Sound;
		
		private var clockSoundChannel:Sound;
		
		public function SoundPlayer()
		{
			PomodoroEventDispatcher.getInstance().addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigurationChange);   	
		}
		
		private function onConfigurationChange(e:ConfigurationUpdatedEvent):void {
			if (e.configElement.name == "sound") {
				soundEnabled = e.configElement.value == "true";
			}
			
			if (e.configElement.name == SoundConfigPanel.FADE_TICKING_SOUND) {
				fadeSound = e.configElement.value == "true";
			}
			
			if (e.configElement.name == "volume") {
				var volume:Number = new Number(e.configElement.value)/100;
				SoundMixer.soundTransform = new SoundTransform(volume);
			}
			
			if (e.configElement.name == SoundConfigPanel.ALARM_SOUND_FILE) {
				trace("Load custom alarm sound: "+e.configElement.value);
				alarmSoundChannel = loadSound(e.configElement.value);
			}
			
			if (e.configElement.name == SoundConfigPanel.CLOCK_SOUND_FILE) {
				trace("Load custom clock sound: "+e.configElement.value);
				clockSound = e.configElement.value;
			}
		}
		
		public function playAlarm():void {
			if (soundEnabled) {
				if (alarmSound != "") {
					trace("Play custom alarm: "+alarmSound);
					alarmSoundChannel.play();
						
				} else {	
					trace("Play default alarm");
					var alarm:Sound = new alarmClass() as Sound;
					alarm.play();
				}
			}
		}
		
		public function playTicTocSound():void {
			if (soundEnabled) {
				if (clockSound != "") {
					trace("Play custom clock sound: "+clockSound);
					
				} else {
					if (fadeSound) {
						trace("Play default clock sound");
						var tick:SoundEffect = new SoundEffect(new tickClass() as Sound); // Weird stuff, need to send sound into constructor...
						tick.volumeFrom = 0.7;
						tick.volumeTo = 0.0;
						tick.volumeEasingFunction = mx.effects.easing.Linear.easeOut;
						tick.duration = 3000;
						tick.useDuration = true;
						tick.source = tickClass; // ..and set it here.
						tick.play();
					} else {
						stopTicTocSound();
						var sound:SoundAsset = new tickClass() as SoundAsset;
						ticToc = sound.play(0, int.MAX_VALUE);
					}
				}
				
			}
		}
		
		public function stopTicTocSound():void {
			if (ticToc != null) {
				ticToc.stop();
			}
		}
		
		
		private function loadSound(file:String):Sound {
			try {
				alarmSound = file;
				var req:URLRequest = new URLRequest(alarmSound);
				if (req.url && req.url != "") {
					 return new Sound(req);
				}
			}  catch (e:Error) {
				Alert.show("Failed to load custom sound: "+file);
			}
			return null;
		}
	}
}
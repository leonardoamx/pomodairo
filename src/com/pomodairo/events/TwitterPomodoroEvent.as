package com.pomodairo.events
{
	import com.iggy.at.api.data.TwitterStatus;
	
	import flash.events.Event;

	public class TwitterPomodoroEvent extends Event
	{
		public static var NEW:String = "pomodoro twitter update";
		
		public var twitterStatus:TwitterStatus;
		
		public var value:String;
		
		public function TwitterPomodoroEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
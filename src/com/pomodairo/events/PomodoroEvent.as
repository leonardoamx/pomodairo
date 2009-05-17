package com.pomodairo.events
{
	import com.pomodairo.Pomodoro;
	
	import flash.events.Event;

	public class PomodoroEvent extends Event
	{
		public static var SELECTED:String = "pomodoro selected";
		public static var TIME_OUT:String = "pomodoro time out";
		public static var UNPLANNED:String = "pomodoro unplanned";
		public static var INTERRUPTION:String = "pomodoro interruption";
		public static var DONE:String = "pomodoro done";
		
		public var pomodoro:Pomodoro;
		
		public var other:Pomodoro;
		
		public function PomodoroEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
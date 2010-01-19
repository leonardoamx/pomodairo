package com.pomodairo.events
{
	import com.pomodairo.Pomodoro;
	
	import flash.events.Event;

	public class PomodoroEvent extends Event
	{
		public static var SELECTED:String = "pomodoro selected";
		public static var DELETED:String = "pomodoro deleted";
		public static var TIME_OUT:String = "pomodoro time out";
		public static var START_POMODORO:String = "pomodoro started";
		public static var STOP_POMODORO:String = "pomodoro stopped";
		public static var NEW_POMODORO:String = "pomodoro created";
		public static var NEW_UNPLANNED:String = "unplanned created";
		public static var NEW_INTERRUPTION:String = "interruption created";
		public static var DONE:String = "pomodoro done";
		public static var EDITED:String = "pomodoro edited";
		public static var TIMER_TICK:String = "timer tick";
		public static var START_BREAK:String = "break started";
		public static var STOP_BREAK:String = "break stopped";
		
		public var pomodoro:Pomodoro;
		
		public var other:Pomodoro;
		
		public var value:String;
		
		public function PomodoroEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
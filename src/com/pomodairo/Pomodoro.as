package com.pomodairo
{
	[Bindable]
	public class Pomodoro
	{
		public static var TYPE_POMODORO:String = "Pomodoro";
		public static var TYPE_INTERRUPTION:String = "Interruption";
		public static var TYPE_UNPLANNED:String = "Unplanned";
		
		public var id:int;
		public var name:String;
		public var type:String;
		public var pomodoros:int = 0;
		public var done:Boolean = false;
		public var unplanned:int = 0;
		public var interruptions:int = 0;
		public var created:Date = new Date();
		public var closed:Date;
		public var parent:int = 0;
		
		// Descriptions
		public var pomodorosDescription:String = "Number of pomodoros used";
		public var unplannedDescription:String = "Number of unplanned items that came up";
		public var interruptionsDescription:String = "Number of interruptions that have occurred";
		
		public function Pomodoro(){}
		
		public function close() 
		{
			closed = new Date();
		}
	}
}
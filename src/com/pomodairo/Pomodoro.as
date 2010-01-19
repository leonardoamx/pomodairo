package com.pomodairo
{
	import flash.events.EventDispatcher;
	
	import mx.formatters.DateFormatter;
	
	[Bindable]
	public class Pomodoro extends EventDispatcher
	{
		public static var TYPE_POMODORO:String = "Pomodoro";
		public static var TYPE_INTERRUPTION:String = "Interruption";
		public static var TYPE_UNPLANNED:String = "Unplanned";
		public static var TYPE_EDIT:String = "Edit";
		
		public var id:int;
		public var name:String;
		public var type:String;
		public var _pomodoros:int = 0;
		public var estimated:int = -1;
		public var done:Boolean = false;
		public var unplanned:int = 0;
		public var _interruptions:int = 0;
		public var created:Date = new Date();
		public var _closed:Date;
		public var parent:int = 0;
		public var visible:Boolean = true;
		public var ordinal:int = 0;
		
		// Descriptions
		public var pomodorosDescription:String = "Number of pomodoros used";
		public var estimatedDescription:String = "Estimated number of pomodoros to be used";
		public var unplannedDescription:String = "Number of unplanned items that came up";
		public var interruptionsDescription:String = "Number of interruptions that have occurred";
		
		public function Pomodoro(){}
		
		public function close():void 
		{
			closed = new Date();
		}
		
		public function set pomodoros(pomodoros:int):void {
			_pomodoros = pomodoros;
        	dispatchEvent(new Event("pomodoroChanged"));
		}
		
		public function get pomodoros():int {
			return _pomodoros;
		}
		
		public function set interruptions(interruptions:int):void {
			_interruptions = interruptions;
        	dispatchEvent(new Event("pomodoroChanged"));
		}
		
		public function get interruptions():int {
			return _interruptions;
		}
		
		public function set closed(closed:Date):void {
			_closed = closed;
        	dispatchEvent(new Event("pomodoroChanged"));
		} 
		
		public function get closed():Date {
			return _closed;
		}
		
		[Bindable(event="pomodoroChanged")]
		public function get shortDescription():String {
			return name + " ("+pomodoros+"/"+estimated+")";
		}
		
		[Bindable(event="pomodoroChanged")]
		public function get longDescription():String {
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "MMM. D, L A";
			var created:String = "";
			if(this.created != null) {
				created = formatter.format(this.created);
			}
			var closed:String = "";
			if(this.closed != null) {
				if(this.created.date == this.closed.date) {
					formatter.formatString = "L A";
				}
				closed = " - " + formatter.format(this.closed);
			}
			var type:String = "";
			if(this.type == TYPE_UNPLANNED) {
				type = "U ";
			}
			
			return "[" + created + closed + "] " + type + shortDescription + " " + (interruptions+unplanned) + "'";
		}
	}
}
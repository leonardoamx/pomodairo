package com.pomodairo.events
{
	import com.pomodairo.ConfigProperty;
	
	import flash.events.Event;

	public class GuiChangeEvent extends Event
	{
		public static var UPDATED:String = "pomodairo.gui.statechange";
		
		public var miniView:Boolean = false;
		
		public function GuiChangeEvent()
		{
			super(UPDATED, false, false);
		}
	}
}
package com.pomodairo.events
{
	import com.pomodairo.ConfigProperty;
	
	import flash.events.Event;

	public class ConfigurationUpdatedEvent extends Event
	{
		public static var UPDATED:String = "config updated";

		public var configElement:ConfigProperty;
		
		public function ConfigurationUpdatedEvent(type:String, name:String, value:String)
		{
			super(type, false, false);
			configElement = new ConfigProperty();
			configElement.name = name;
			configElement.value = value;
		}
	}
}
package com.pomodairo
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * Singleton event dispatcher for pomodairo events
	 */
	public class PomodoroEventDispatcher extends EventDispatcher
	{
		private static var instance:PomodoroEventDispatcher = new PomodoroEventDispatcher();
		
		public function PomodoroEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance():PomodoroEventDispatcher {
			return instance;
		}
		
	}
}
package com.pomodairo
{
	import com.pomodairo.db.Storage;
	
	import mx.collections.ArrayCollection;
	
	public class TaskManager
	{
	
		public static var instance:TaskManager = new TaskManager();
		
		[Bindable]
		public var activeTask:Pomodoro; 		

		private var db:Storage = Storage.instance;
		
		private var openTasks:ArrayCollection = new ArrayCollection();

		public function TaskManager() {
			db.initAndOpenDatabase();
			openTasks = db.getOpenPomodoros();
		}
		
		public function nextTask():Boolean {
			refresh();
			
			if(openTasks.length == 0) {
				activeTask = null;
				return false;
			}
			var currentIndex:int = getItemIndex(activeTask);
			// End of list reached. Select first element.
			if(currentIndex >= (openTasks.length -1)) {
				activeTask = Pomodoro(openTasks.getItemAt(0));
			}
			// Select next element in list.
			else {
				activeTask = Pomodoro(openTasks.getItemAt(currentIndex+1));
			}
			trace("Next task is '" + activeTask.name + "'.");
			return true;
		}
		
		public function setActive(task:Pomodoro):void {
			refresh();
			
			if(getItemIndex(task) >= 0) {
				activeTask = task;
				trace("Activated task '"+task.name+"'.");
			}
			else {
				trace("Task '"+task.name+"' is not in list of open tasks.");
			}
		}
		
		public function hasMoreTasks():Boolean {
			if(openTasks.length > 1) {
				return true;
			}
			return false;
		}
		
		private function refresh():void {
			// TODO: Call refresh method.
			openTasks = db.getOpenPomodoros();
		}
		
		private function getItemIndex(item:Pomodoro):int {
			for(var i:int; i < openTasks.length; i++) {
				var curItem:Pomodoro = Pomodoro(openTasks.getItemAt(i));
				if(curItem.created.time == item.created.time) {
					return i;	
				}
			}
			return -1;
		}

	}
}